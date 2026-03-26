class HomeResponse {
  int? statusCode;
  String? message;
  HomeData? data;
  RestaurantPagination? restaurants;

  HomeResponse({
    this.statusCode,
    this.message,
    this.data,
    this.restaurants,
  });

  HomeResponse.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    message = json['message'];
    data = json['data'] != null ? HomeData.fromJson(json['data']) : null;
    restaurants = json['restaurants'] != null
        ? RestaurantPagination.fromJson(json['restaurants'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['statusCode'] = statusCode;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    if (restaurants != null) {
      data['restaurants'] = restaurants!.toJson();
    }
    return data;
  }
}

class HomeData {
  List<Category>? categories;
  List<Coupon>? coupons;
  List<PopularFood>? popularFoods;
  List<Restaurant>? popularRestaurants;

  HomeData({
    this.categories,
    this.coupons,
    this.popularFoods,
    this.popularRestaurants,
  });

  HomeData.fromJson(Map<String, dynamic> json) {
    if (json['categories'] != null) {
      categories = [];
      json['categories'].forEach((v) {
        categories!.add(Category.fromJson(v));
      });
    }

    if (json['coupons'] != null) {
      coupons = [];
      json['coupons'].forEach((v) {
        coupons!.add(Coupon.fromJson(v));
      });
    }

    if (json['popular_foods'] != null) {
      popularFoods = [];
      json['popular_foods'].forEach((v) {
        popularFoods!.add(PopularFood.fromJson(v));
      });
    }

    if (json['popular_restaurants'] != null) {
      popularRestaurants = [];
      json['popular_restaurants'].forEach((v) {
        popularRestaurants!.add(Restaurant.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    if (coupons != null) {
      data['coupons'] = coupons!.map((v) => v.toJson()).toList();
    }
    if (popularFoods != null) {
      data['popular_foods'] = popularFoods!.map((v) => v.toJson()).toList();
    }
    if (popularRestaurants != null) {
      data['popular_restaurants'] =
          popularRestaurants!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Category {
  int? id;
  String? name;
  String? description;
  String? image;
  bool? isActive;

  Category({
    this.id,
    this.name,
    this.description,
    this.image,
    this.isActive,
  });

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    image = json['image'];
    isActive = json['is_active'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'is_active': isActive,
    };
  }
}

class Coupon {
  int? id;
  String? code;
  String? description;
  String? discountType;
  String? discountValue;
  String? discountDisplay;
  String? minOrderValue;
  String? maxDiscountAmount;
  String? validFrom;
  String? validTill;
  int? usageLimit;
  int? usagePerUser;
  bool? isActive;
  bool? isValid;

  Coupon({
    this.id,
    this.code,
    this.description,
    this.discountType,
    this.discountValue,
    this.discountDisplay,
    this.minOrderValue,
    this.maxDiscountAmount,
    this.validFrom,
    this.validTill,
    this.usageLimit,
    this.usagePerUser,
    this.isActive,
    this.isValid,
  });

  Coupon.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    description = json['description'];
    discountType = json['discount_type'];
    discountValue = json['discount_value'];
    discountDisplay = json['discount_display'];
    minOrderValue = json['min_order_value'];
    maxDiscountAmount = json['max_discount_amount'];
    validFrom = json['valid_from'];
    validTill = json['valid_till'];
    usageLimit = json['usage_limit'];
    usagePerUser = json['usage_per_user'];
    isActive = json['is_active'];
    isValid = json['is_valid'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'description': description,
      'discount_type': discountType,
      'discount_value': discountValue,
      'discount_display': discountDisplay,
      'min_order_value': minOrderValue,
      'max_discount_amount': maxDiscountAmount,
      'valid_from': validFrom,
      'valid_till': validTill,
      'usage_limit': usageLimit,
      'usage_per_user': usagePerUser,
      'is_active': isActive,
      'is_valid': isValid,
    };
  }
}

class PopularFood {
  int? id;
  String? name;
  String? price;
  String? category;
  RestaurantInfo? restaurant;
  String? image;

  PopularFood({
    this.id,
    this.name,
    this.price,
    this.category,
    this.restaurant,
    this.image,
  });

  PopularFood.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'];
    category = json['category'];
    restaurant = json['restaurant'] != null
        ? RestaurantInfo.fromJson(json['restaurant'])
        : null;
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'restaurant': restaurant?.toJson(),
      'image': image,
    };
  }
}

class RestaurantInfo {
  int? id;
  String? name;

  RestaurantInfo({this.id, this.name});

  RestaurantInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Restaurant {
  int? id;
  String? businessName;
  String? ownerName;
  String? phone;
  String? pincode;
  bool? isAcceptingOrders;
  Rating? rating;
  double? distance;
  String? deliveryFee;
  bool? availability;
  String? address;
  String? image;

  Restaurant({
    this.id,
    this.businessName,
    this.ownerName,
    this.phone,
    this.pincode,
    this.deliveryFee,
    this.isAcceptingOrders,
    this.rating,
    this.distance,
    this.availability,
    this.address,
    this.image,
  });

  Restaurant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    businessName = json['business_name'];
    ownerName = json['owner_name'];
    phone = json['phone'];
    deliveryFee = json['deliveryFee'] ?? "0";
    pincode = json['pincode'];
    isAcceptingOrders = json['is_accepting_orders'];
    rating = json['rating'] != null ? Rating.fromJson(json['rating']) : null;
    distance = json['distance'] != null
        ? double.tryParse(json['distance'].toString())
        : null;
    availability = json['availability'];
    address = json['address'];
    image = json['image'] ??
        "https://lh3.googleusercontent.com/gps-cs-s/AHVAwepJq6ir47u82guAVTnYkHeVg8MuVUHxZ6Qrxvz58KqAEZiYlo6L9ZdXZsIrRNEnKnF2sxO5HckpbQkLqpSTOCszYxjC7fn_Z26E3zOIipqS91PvSiJj-YO-8rILHnm2A7umIkYPxQ=s1360-w1360-h1020-rw";
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_name': businessName,
      'owner_name': ownerName,
      'phone': phone,
      'pincode': pincode,
      'is_accepting_orders': isAcceptingOrders,
      'rating': rating?.toJson(),
      'distance': distance,
      'availability': availability,
      'address': address,
      'image': image,
    };
  }
}

class Rating {
  double? average;
  int? count;

  Rating({this.average, this.count});

  Rating.fromJson(Map<String, dynamic> json) {
    average = json['average'] != null
        ? double.tryParse(json['average'].toString())
        : null;
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    return {
      'average': average,
      'count': count,
    };
  }
}

class RestaurantPagination {
  int? count;
  String? next;
  String? previous;
  List<Restaurant>? results;

  RestaurantPagination({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  RestaurantPagination.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];

    if (json['results'] != null) {
      results = [];
      json['results'].forEach((v) {
        results!.add(Restaurant.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results?.map((v) => v.toJson()).toList(),
    };
  }
}
