class OrderHistoryData {
  int? statusCode;
  String? message;
  Data? data;

  OrderHistoryData({this.statusCode, this.message, this.data});

  OrderHistoryData.fromJson(Map<String, dynamic> json) {
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
  int? count;
  String? next;
  String? previous;
  List<Results>? results;

  Data({this.count, this.next, this.previous, this.results});

  Data.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    if (json['results'] != null) {
      results = <Results>[];
      json['results'].forEach((v) {
        results!.add(new Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    data['next'] = this.next;
    data['previous'] = this.previous;
    if (this.results != null) {
      data['results'] = this.results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Results {
  int? id;
  String? orderNumber;
  String? restaurantName;
  String? restaurantImage;
  String? totalAmount;
  String? status;
  String? createdAt;
  String? deliveredAt;
  int? itemsCount;

  Results({this.id,
    this.orderNumber,
    this.restaurantName,
    this.restaurantImage,
    this.totalAmount,
    this.status,
    this.createdAt,
    this.deliveredAt,
    this.itemsCount});

  Results.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderNumber = json['order_number'];
    restaurantName = json['restaurant_name'];
    restaurantImage = json['restaurant_image'] ??
        "https://media.istockphoto.com/id/1829241109/photo/enjoying-a-brunch-together.jpg?s=612x612&w=0&k=20&c=9awLLRMBLeiYsrXrkgzkoscVU_3RoVwl_HA-OT-srjQ=";
    ;
    totalAmount = json['total_amount'];
    status = json['status'];
    createdAt = json['created_at'];
    deliveredAt = json['delivered_at'];
    itemsCount = json['items_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['order_number'] = this.orderNumber;
    data['restaurant_name'] = this.restaurantName;
    data['restaurant_image'] = this.restaurantImage;
    data['total_amount'] = this.totalAmount;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['delivered_at'] = this.deliveredAt;
    data['items_count'] = this.itemsCount;
    return data;
  }
}
