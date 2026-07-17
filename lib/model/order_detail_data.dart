class OrderDetailData {
  int? statusCode;
  String? message;
  Data? data;

  OrderDetailData({this.statusCode, this.message, this.data});

  OrderDetailData.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  String? orderNumber;
  String? status;
  String? restaurantName;
  String? restaurantPhone;
  String? restaurantImage;
  String? customerPhone;
  String? deliveryAddress;
  String? deliveryPincode;
  List<Items>? items;
  String? itemsTotal;
  String? deliveryFee;
  String? platformFee;
  String? totalAmount;
  String? paymentMethod;
  double? preparationTime;
  String? estimatedReadyAt;
  String? createdAt;
  String? acceptedAt;
  String? readyAt;
  String? pickedAt;
  String? deliveredAt;
  String? discountAmount;
  String? couponCode;
  String? walletDeduction;
  DeliveryPartner? deliveryPartner;

  Data(
      {this.id,
      this.orderNumber,
      this.status,
      this.restaurantName,
      this.restaurantPhone,
      this.restaurantImage,
      this.customerPhone,
      this.deliveryAddress,
      this.deliveryPincode,
      this.items,
      this.itemsTotal,
      this.deliveryFee,
      this.platformFee,
      this.totalAmount,
      this.paymentMethod,
      this.preparationTime,
      this.estimatedReadyAt,
      this.createdAt,
      this.acceptedAt,
      this.readyAt,
      this.pickedAt,
      this.deliveredAt,
      this.discountAmount,
      this.couponCode,
      this.walletDeduction,
      this.deliveryPartner});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderNumber = json['order_number'];
    status = json['status'];
    restaurantName = json['restaurant_name'];
    restaurantPhone = json['restaurant_phone'];
    restaurantImage = json['restaurant_image'];
    customerPhone = json['customer_phone'];
    deliveryAddress = json['delivery_address'];
    deliveryPincode = json['delivery_pincode'];
    if (json['items'] != null) {
      print("asasa");
      items = <Items>[];
      print(items);
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
      });
    }
    itemsTotal = json['items_total'];
    deliveryFee = json['delivery_fee'];
    platformFee = json['platform_fee'];
    totalAmount = json['total_amount'];
    paymentMethod = json['payment_method'];
    preparationTime = json['preparation_time'] != null
        ? json['preparation_time'].toDouble()
        : 0;
    estimatedReadyAt = json['estimated_ready_at'];
    createdAt = json['created_at'];
    acceptedAt = json['accepted_at'];
    readyAt = json['ready_at'];
    pickedAt = json['picked_at'];
    deliveredAt = json['delivered_at'];
    discountAmount =
        (json['discount_amount'] ?? json['discount'] ?? json['coupon_amount'])
            ?.toString();
    couponCode = json['coupon_code']?.toString();
    walletDeduction = json['wallet_deduction']?.toString();
    deliveryPartner = json['delivery_partner'] != null
        ? new DeliveryPartner.fromJson(json['delivery_partner'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['order_number'] = this.orderNumber;
    data['status'] = this.status;
    data['restaurant_name'] = this.restaurantName;
    data['restaurant_phone'] = this.restaurantPhone;
    data['restaurant_image'] = this.restaurantImage;
    data['customer_phone'] = this.customerPhone;
    data['delivery_address'] = this.deliveryAddress;
    data['delivery_pincode'] = this.deliveryPincode;
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    data['items_total'] = this.itemsTotal;
    data['delivery_fee'] = this.deliveryFee;
    data['platform_fee'] = this.platformFee;
    data['total_amount'] = this.totalAmount;
    data['payment_method'] = this.paymentMethod;
    data['preparation_time'] = this.preparationTime;
    data['estimated_ready_at'] = this.estimatedReadyAt;
    data['created_at'] = this.createdAt;
    data['accepted_at'] = this.acceptedAt;
    data['ready_at'] = this.readyAt;
    data['picked_at'] = this.pickedAt;
    data['delivered_at'] = this.deliveredAt;
    data['discount_amount'] = this.discountAmount;
    data['coupon_code'] = this.couponCode;
    data['wallet_deduction'] = this.walletDeduction;
    if (this.deliveryPartner != null) {
      data['delivery_partner'] = this.deliveryPartner!.toJson();
    }
    return data;
  }
}

class Items {
  String? itemName;
  String? itemPrice;
  int? quantity;
  String? subtotal;

  Items({this.itemName, this.itemPrice, this.quantity, this.subtotal});

  Items.fromJson(Map<String, dynamic> json) {
    itemName = json['item_name'];
    itemPrice = json['item_price'];
    quantity = json['quantity'];
    subtotal = json['subtotal'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['item_name'] = this.itemName;
    data['item_price'] = this.itemPrice;
    data['quantity'] = this.quantity;
    data['subtotal'] = this.subtotal;
    return data;
  }
}

class DeliveryPartner {
  int? id;
  String? name;
  String? phone;
  String? vehicleNumber;
  String? vehicleType;
  double? currentLatitude;
  double? currentLongitude;
  double? averageRating;

  DeliveryPartner({
    this.id,
    this.name,
    this.phone,
    this.vehicleNumber,
    this.vehicleType,
    this.currentLatitude,
    this.currentLongitude,
    this.averageRating,
  });

  DeliveryPartner.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone']?.toString();
    vehicleNumber = json['vehicle_number'];
    vehicleType = json['vehicle_type'];
    currentLatitude = json['current_latitude']?.toDouble();
    currentLongitude = json['current_longitude']?.toDouble();
    averageRating = json['average_rating']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['phone'] = this.phone;
    data['vehicle_number'] = this.vehicleNumber;
    data['vehicle_type'] = this.vehicleType;
    data['current_latitude'] = this.currentLatitude;
    data['current_longitude'] = this.currentLongitude;
    data['average_rating'] = this.averageRating;
    return data;
  }
}
