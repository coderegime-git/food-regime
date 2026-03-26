import 'dart:convert';

import 'package:food_delivery_app/model/profile_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static late SharedPreferences _prefs;

  static Future<SharedPreferences> init() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs;
  }

  // Sets
  static Future<bool> setBool(String key, bool value) async =>
      await _prefs.setBool(key, value);

  static Future<bool> setDouble(String key, double value) async =>
      await _prefs.setDouble(key, value);

  static Future<bool> setInt(String key, int value) async =>
      await _prefs.setInt(key, value);

  static Future<bool> setString(String key, String value) async =>
      await _prefs.setString(key, value);

  static Future<bool> setStringList(String key, List<String> value) async =>
      await _prefs.setStringList(key, value);

  // Gets
  static bool? getBool(String key) => _prefs.getBool(key);

  static double? getDouble(String key) => _prefs.getDouble(key);

  static int? getInt(String key) => _prefs.getInt(key);

  static String? getString(String key) => _prefs.getString(key);

  static List<String>? getStringList(String key) => _prefs.getStringList(key);

  // Deletes..
  static Future<bool>? remove(String key) async => await _prefs.remove(key);

  static Future<bool> clear() async => await _prefs.clear();

  static String? getThemeMode() {
    return getString('theme_mode');
  }

  static void setThemeMode(String mode) {
    setString('theme_mode', mode);
  }

  static String? getUserId() {
    return getString('user_id');
  }

  static void setUserId(String userId) {
    setString('user_id', userId);
  }

  static String? getFirebaseToken() {
    return getString('fcm_token');
  }

  static void setFirebaseToken(String token) {
    setString('fcm_token', token);
  }

  static String? getAuthToken() {
    return getString('auth_token');
  }

  static void setAuthToken(String token) {
    setString('auth_token', token);
  }

  static void saveRefreshToken(String token) {
    setString('refresh_token', token);
  }

  static ProfileData getUserObject() {
    if (getString('user_data') != null) {
      Map<String, dynamic> json = jsonDecode(getString('user_data')!);
      return ProfileData.fromJson(json);
    } else {
      return ProfileData(statusCode: 0, data: Data());
    }
  }

  static void setUserObject(ProfileData userData) {
    String user = jsonEncode(userData);
    setString('user_data', user);
  }

  static String? getLocale() {
    return getString('locale');
  }

  static String? getRefreshToken() {
    return getString('refresh_token');
  }

  static void setLocale(String locale) {
    setString('locale', locale);
  }

  static String? getUserCurrency() {
    return getString('currency_code');
  }

  static void setUserCurrency(String currencyCode) {
    setString('currency_code', currencyCode);
  }

  //
  // static Future<void> setServiceTypes(List<ServiceTypes> serviceTypes) async {
  //   final jsonString =
  //   jsonEncode(serviceTypes.map((type) => type.toJson()).toList());
  //   setString("service_type", jsonString);
  // }
  //
  // static Future<List<ServiceTypes>> getServiceTypes() async {
  //   final jsonString = getString("service_type");
  //   if (jsonString != null) {
  //     final jsonList = jsonDecode(jsonString) as List<dynamic>;
  //     return jsonList.map((json) => ServiceTypes.fromJson(json)).toList();
  //   }
  //   return [];
  // }

  static int? getServiceTypesId() {
    return getInt('service_types_id');
  }

  static void setServiceTypesId(int serviceTypesId) {
    setInt('service_types_id', serviceTypesId);
  }

  // static UserAddresses? getUserAddress() {
  //   String? jsonString = getString('user_address');
  //   if (jsonString != null) {
  //     Map<String, dynamic> json = jsonDecode(jsonString);
  //     return UserAddresses.fromJson(json);
  //   }
  //   return null;
  // }

  // static void setUserAddress(UserAddresses userAddress) {
  //   String user = jsonEncode(userAddress);
  //   setString('user_address', user);
  // }
  //
  // static Future<void> setMenuItems(List<MenuItems> menuItems) async {
  //   final jsonString =
  //   jsonEncode(menuItems.map((type) => type.toJson()).toList());
  //   setString("menu_items", jsonString);
  // }

  static Future setRecentSearch(List<String> recentSearch) async {
    setStringList('recent_searches', recentSearch);
  }

  // static Future<List<MenuItems>> getMenuItems() async {
  //   final jsonString = getString("menu_items");
  //   if (jsonString != null) {
  //     final jsonList = jsonDecode(jsonString) as List<dynamic>;
  //     return jsonList.map((json) => MenuItems.fromJson(json)).toList();
  //   }
  //   return [];
  // }

  static int? getStoreId() {
    return getInt('store_id');
  }

  static void setStoreId(int storeId) {
    setInt('store_id', storeId);
  }

  static bool? getAddress() {
    return getBool('on_board');
  }

  static List<String>? getRecentSearch() {
    return getStringList('recent_searches');
  }

  static void setAddress(bool value) {
    setBool('on_board', value);
  }

  static void setLatAndLong(String latitude, String longitude) {
    Map result = {"latitude": latitude, "longitude": longitude};
    String latLong = jsonEncode(result);
    setString('lat_long', latLong);
  }

  static String? getLatLong() {
    return getString('lat_long');
  }

  static int? getRemainingSec() {
    return getInt('seconds');
  }

  static void setRemainingSec(int seconds) {
    setInt('seconds', seconds);
  }

  static String? getTime() {
    return getString('time');
  }

  static void setTime(String time) {
    setString('time', time);
  }
}
