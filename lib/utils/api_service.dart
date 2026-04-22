import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/model/cart_data.dart';
import 'package:food_delivery_app/model/home_data.dart' as home_data;
import 'package:food_delivery_app/model/notification_data.dart';
import 'package:food_delivery_app/model/order_detail_data.dart';
import 'package:food_delivery_app/model/profile_data.dart';
import 'package:food_delivery_app/routes/app_routes.dart';
import 'package:food_delivery_app/utils/sharedpreference_helper.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../exception/api_exception.dart';
import '../model/app_data.dart';
import '../model/order_history_data.dart';
import '../model/restauant_detail_data.dart';
import '../model/search_result_data.dart';
import '../model/static_page_data.dart';
import 'helper.dart';

late GlobalKey<NavigatorState> _navigatorKey;

clearUserData() async {
  // Clear all stored tokens and user data
  await SharedPreferenceHelper.clear();
  // TODO: Navigate to login screen
  // _navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (_) => false);
}

class ApiBaseHelper {
  initApiService(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  static const _baseUrl = "${AppConstants.baseUrl}api/";

  final Dio dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 300),
  ));

  // ─── Flag to prevent multiple simultaneous refresh calls ─────────────────
  bool _isRefreshing = false;

  // Queue of requests waiting for token refresh to complete
  final List<Completer<String?>> _refreshQueue = [];

  // ─── Response Handler ─────────────────────────────────────────────────────

  dynamic _returnResponse(Response response) {
    switch (response.statusCode) {
      case 200 || 201:
        return response.data;
      case 400:
        throw BadRequestException(response.data.toString());
      case 401:
      case 403:
        throw UnAuthorisedException(response.data.toString());
      case 500:
      default:
        throw FetchDataException(
            'Error occurred while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }

  // ─── Headers ──────────────────────────────────────────────────────────────

  Map<String, String> getMainHeaders({String? overrideToken}) {
    String? token = overrideToken ?? SharedPreferenceHelper.getAuthToken();
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    print(headers);
    return headers;
  }

  // ─── Refresh Token ────────────────────────────────────────────────────────

  /// Calls the refresh token API, saves the new token, and returns it.
  /// Returns null if refresh fails (forces logout).
  Future<String?> _refreshToken() async {
    // If already refreshing, wait for it to complete instead of making
    // duplicate refresh calls
    if (_isRefreshing) {
      final completer = Completer<String?>();
      _refreshQueue.add(completer);
      return completer.future;
    }

    _isRefreshing = true;

    try {
      final refreshToken = SharedPreferenceHelper.getRefreshToken();

      if (refreshToken == null) {
        _onRefreshFailed();
        return null;
      }

      final refreshDio = Dio(BaseOptions(baseUrl: _baseUrl));

      final response = await refreshDio.post(
        "auth/refresh-token/", // 👈 replace with your actual endpoint
        data: jsonEncode({"refresh": refreshToken}),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      print(response);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final newAccessToken =
            response.data['access_token']; // 👈 adjust key to match your API
        final newRefreshToken = response
            .data['refresh_token']; // save if your API rotates refresh tokens

        // Persist new token
        SharedPreferenceHelper.setAuthToken(newAccessToken);
        SharedPreferenceHelper.saveRefreshToken(newRefreshToken); // if rotated

        // Resolve all waiting requests with the new token
        for (final c in _refreshQueue) {
          c.complete(newAccessToken);
        }
        _refreshQueue.clear();

        return newAccessToken;
      } else {
        _onRefreshFailed();
        return null;
      }
    } catch (e) {
      _onRefreshFailed();
      return null;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Called when refresh token is invalid or expired — force logout
  void _onRefreshFailed() {
    for (final c in _refreshQueue) {
      c.complete(null);
    }
    _refreshQueue.clear();
    clearUserData();
  }

  // ─── Error Handler (shared across GET/POST/PATCH/PUT/DELETE) ─────────────

  /// Returns a new token if the error was 401 and refresh succeeded.
  /// Throws for all other errors.
  Future<String?> _handleError(dynamic e) async {
    final errorStr = e.toString();

    if (errorStr.contains("401")) {
      // Attempt to refresh the token
      debugPrint("Attempt to refresh the token");
      final newToken = await _refreshToken();
      if (newToken != null) {
        return newToken; // caller should retry the original request
      }
      throw Exception('token_expired');
    } else if (errorStr.contains("403")) {
      ScaffoldMessenger.of(_navigatorKey.currentContext!).showSnackBar(
        const SnackBar(
          content:
              Text("Your account has been suspended. Please contact admin."),
        ),
      );
      clearUserData();
      throw Exception('user_inactive');
    } else if (errorStr.contains("500") || errorStr.contains("404")) {
      Helper().showToast(
          _navigatorKey.currentContext!, "invalid_response_try_again_later", 0);
      throw Exception('server_error');
    } else {
      Helper().showToast(
          _navigatorKey.currentContext!, "no_internet_connection", 0);
      throw Exception('no_internet_connection');
    }
  }

  // ─── HTTP Methods ─────────────────────────────────────────────────────────

  Future<dynamic> get(String url) async {
    Helper().printMessage(_baseUrl + url);

    try {
      final response = await dio.get(
        url,
        options: Options(headers: getMainHeaders()),
      );
      return _returnResponse(response);
    } catch (e) {
      try {
        final newToken = await _handleError(e);

        // Retry only if token refreshed
        if (newToken != null) {
          final response = await dio.get(
            url,
            options: Options(headers: getMainHeaders(overrideToken: newToken)),
          );
          return _returnResponse(response);
        }

        throw Exception("Retry failed");
      } catch (err) {
        // 🔥 VERY IMPORTANT: handle token expired
        if (err.toString().contains('token_expired')) {
          clearUserData();
          if (_navigatorKey.currentContext == null) return;
          _navigatorKey.currentContext!.push(AppRoutes.loginPath(false));
        }

        rethrow;
      }
    }
  }

  Future<dynamic> post(String url, [dynamic body]) async {
    Helper().printMessage(_baseUrl + url);
    try {
      final response = await dio.post(
        url,
        data: jsonEncode(body),
        options: Options(headers: getMainHeaders()),
      );
      return _returnResponse(response);
    } catch (e) {
      print(e.toString());
      final newToken = await _handleError(e);
      final response = await dio.post(
        url,
        data: jsonEncode(body),
        options: Options(headers: getMainHeaders(overrideToken: newToken)),
      );
      return _returnResponse(response);
    }
  }

  Future<dynamic> patch(String url, [dynamic body]) async {
    Helper().printMessage(_baseUrl + url);
    try {
      final response = await dio.patch(
        url,
        data: jsonEncode(body),
        options: Options(headers: getMainHeaders()),
      );
      return _returnResponse(response);
    } catch (e) {
      final newToken = await _handleError(e);
      final response = await dio.patch(
        url,
        data: jsonEncode(body),
        options: Options(headers: getMainHeaders(overrideToken: newToken)),
      );
      return _returnResponse(response);
    }
  }

  Future<dynamic> put(String url, [dynamic body]) async {
    try {
      final response = await dio.put(
        url,
        data: jsonEncode(body),
        options: Options(headers: getMainHeaders()),
      );
      return _returnResponse(response);
    } catch (e) {
      final newToken = await _handleError(e);
      final response = await dio.put(
        url,
        data: jsonEncode(body),
        options: Options(headers: getMainHeaders(overrideToken: newToken)),
      );
      return _returnResponse(response);
    }
  }

  Future<dynamic> delete(String url) async {
    try {
      final response = await dio.delete(
        url,
        options: Options(headers: getMainHeaders()),
      );
      return _returnResponse(response);
    } catch (e) {
      final newToken = await _handleError(e);
      final response = await dio.delete(
        url,
        options: Options(headers: getMainHeaders(overrideToken: newToken)),
      );
      return _returnResponse(response);
    }
  }
}

// ─── ApiService (unchanged) ──────────────────────────────────────────────────

class ApiService {
  final ApiBaseHelper _helper = ApiBaseHelper();

  Future<dynamic> sendOTP({required String phoneNumber}) async {
    return await _helper
        .post("auth/send-otp/", {"phone": phoneNumber, "role": "customer"});
  }

  Future<dynamic> verifyOTP(
      {required String phoneNumber, required String otp}) async {
    return await _helper.post("auth/verify-otp/",
        {"phone": phoneNumber, "role": "customer", "otp": otp});
  }

  Future<home_data.HomeResponse> getHomeData(page) async {
    final data = await _helper.get("customer/home/?page$page&limit=15");
    return home_data.HomeResponse.fromJson(data);
  }

  Future<ProfileData> getProfile() async {
    final data = await _helper.get("customer/profile/");
    return profileDataFromJson(data);
  }

  Future<ProfileData> updateProfile(body) async {
    final data = await _helper.patch("customer/profile/", body);

    return profileDataFromJson(data);
  }

  Future<dynamic> getSavedAddress() async {
    final data = await _helper.get("customer/addresses/");

    return data;
  }

  Future<dynamic> addNewAddress(body) async {
    final data = await _helper.post("customer/addresses/", body);
    return data;
  }

  Future<dynamic> updateNewAddress(id, body) async {
    final data = await _helper.patch("customer/addresses/$id/", body);
    return data;
  }

  Future<dynamic> deleteAddress(id) async {
    final data = await _helper.delete("customer/addresses/$id/");

    return data;
  }

  Future<OrderHistoryData> getOrderHistory(
      {required String pageNo, required String status}) async {
    final url = status == "all"
        ? "customer/orders/history?page=$pageNo&limit=10"
        : "customer/orders/history?page=$pageNo&limit=10&status=$status";
    final data = await _helper.get(url);

    return OrderHistoryData.fromJson(data);
  }

  Future<OrderDetailData> getOrderDetails(id) async {
    final data = await _helper.get("orders/$id/details");
    return OrderDetailData.fromJson(data);
  }

  Future<Restaurant> getRestaurantDetails(id) async {
    final data = await _helper.get("restaurants/$id/");
    return Restaurant.fromJson(data);
  }

  Future<Map<String, dynamic>> cancelOrder(id, reason) async {
    final data = await _helper.post("orders/$id/cancel/", {"reason": reason});

    return data;
  }

  Future<Map<String, dynamic>> repeatOrder(id) async {
    final data = await _helper.post("orders/$id/repeat/", {});

    return data;
  }

  Future<Map<String, dynamic>> submitReview(
      {required String orderId,
      required String restaurantRating,
      required String riderRating,
      required String review}) async {
    final data = await _helper.post("orders/$orderId/rate/", {
      "restaurant_rating": restaurantRating,
      "rider_rating": riderRating,
      "review": "Great food!"
    });
    return data;
  }

  Future<Map<String, dynamic>> getOrderRatings(
      {required String orderId}) async {
    final data = await _helper.get("orders/$orderId/rating/");
    return data;
  }

  Future<CartData> getCart() async {
    final data = await _helper.get("customer/cart/");

    return CartData.fromJson(data);
  }

  Future<Map<String, dynamic>> addCart({
    required int menuItemId,
    required int quantity,
  }) async {
    final body = {
      'menu_item_id': menuItemId,
      'quantity': quantity,
    };
    debugPrint('addCart body → $body');
    final data = await _helper.post("customer/cart/add-item/", body);

    return data;
  }

  // POST cart/update-item/
  Future<Map<String, dynamic>> updateCart({
    required int cartItemId,
    required int quantity,
  }) async {
    final body = {
      'cart_item_id': cartItemId,
      'quantity': quantity,
    };
    debugPrint('updateCart body → $body');
    final data = await _helper.post("customer/cart/update-item/", body);
    return data;
  }

  Future<Map<String, dynamic>> removeCart({required int cartItemId}) async {
    final body = {'cart_item_id': cartItemId};
    debugPrint('removeCart body → $body');
    final data = await _helper.post("customer/cart/remove-item/", body);
    return data;
  }

  Future<Map<String, dynamic>> removeAllCart() async {
    final data = await _helper.post("customer/cart/clear/", {});
    return data;
  }

  // POST api/create-order/
  Future<Map<String, dynamic>> placeOrder({
    required String deliveryAddressId,
    required String paymentMethod,
    required String couponCode,
    required bool useWallet,
  }) async {
    final body = {
      "delivery_address_id": deliveryAddressId,
      "payment_method":
          paymentMethod.toString().contains("cod") ? "cod" : "online",
      "coupon_code": couponCode,
      "use_wallet": useWallet,
      "customer_notes": "No onions please"
    };
    debugPrint('placeOrder body → $body');
    final data = await _helper.post("customer/checkout/confirm/", body);
    return data;
  }

  Future<SearchResult> search(String query) async {
    final res = await _helper.get('search/?q=$query');
    return SearchResult.fromJson(res);
  }

  Future<Map<String, dynamic>> updateFCMToken({required String fcm}) async {
    final res = await _helper.post('auth/fcm-token/', {"fcm_token": fcm});
    return res;
  }

  Future<Map<String, dynamic>> deleteFCMToken() async {
    final res = await _helper.delete('auth/fcm-token/');
    return res;
  }

  Future<Map<String, dynamic>> applyCoupon({
    required String code,
  }) async {
    final res = await _helper.post('customer/coupon/apply/', {"code": code});
    return res;
  }

  Future<Map<String, dynamic>> validateCoupon(
      {required String code, required String orderTotal}) async {
    final res = await _helper.post(
        'customer/coupon/validate/', {"code": code, "order_total": orderTotal});
    return res;
  }

  Future<NotificationData> getNotification() async {
    final res = await _helper.get(
      'customer/notifications/',
    );
    return NotificationData.fromJson(res);
  }

  Future<Map<String, dynamic>> markNotificationRead(
      {required int notificationId}) async {
    final res = await _helper.post(
        'customer/notifications/read/', {"notification_id": notificationId});
    return res;
  }

  Future<StaticPageData> getStaticPage({required String page}) async {
    final res = await _helper.get(
      'static-pages/?page_type=$page&role=customer',
    );
    return StaticPageData.fromJson(res);
  }

  Future<Map<String, dynamic>> deleteAccount({required String userId}) async {
    final res = await _helper.get(
      'customer/$userId/delete-account/',
    );
    return res;
  }

  Future<Map<String, dynamic>> getWallet() async {
    try {
      final resp = await _helper.get('customer/wallet/transactions/');
      return resp;
    } catch (e) {
      return {'statusCode': 0, 'message': e.toString()};
    }
  }

  /// POST /wallet/add/  body: { "amount": 500 }

  Future<Map<String, dynamic>> addMoneyToWallet(
      {required String amount}) async {
    final res =
        await _helper.post('customer/wallet/add-funds/', {"amount": amount});
    return res;
  }

  Future<Map<String, dynamic>> getCheckoutPreview({
    String? couponCode,
    bool useWallet = false,
  }) async {
    String url = 'customer/checkout/preview/';
    final params = <String>[];
    if (couponCode != null && couponCode.isNotEmpty) {
      params.add('coupon_code=$couponCode');
    }
    if (useWallet) params.add('use_wallet=true');
    if (params.isNotEmpty) url += '?${params.join('&')}';
    print(url);
    final response = await _helper.get(url);
    print(response);
    return response;
  }

  Future<AppUpdateData> checkUpdateRequired() async {
    try {
      final platform = Platform.isAndroid ? "android" : "ios";
      final res =
          await _helper.get('app-version/?platform=$platform&role=customer');
      print(res);
      return AppUpdateData.fromJson(res);
    } catch (e) {
      return AppUpdateData.fromJson({});
    }
  }
}
