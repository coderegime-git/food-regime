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
      this.deliveredAt});

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
