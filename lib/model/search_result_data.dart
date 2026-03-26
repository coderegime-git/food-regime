class SearchRestaurant {
  final int id;
  final String businessName;
  final String address;
  final String pincode;
  final bool isAcceptingOrders;
  final String deliveryFee;
  final String? image;

  SearchRestaurant({
    required this.id,
    required this.businessName,
    required this.address,
    required this.pincode,
    required this.isAcceptingOrders,
    required this.deliveryFee,
    this.image,
  });

  factory SearchRestaurant.fromJson(Map<String, dynamic> j) => SearchRestaurant(
        id: j['id'],
        businessName: j['business_name'],
        address: j['address'],
        pincode: j['pincode'],
        isAcceptingOrders: j['is_accepting_orders'],
        deliveryFee: j['delivery_fee_per_order'],
        image: j['image'] ??
            "https://pub-aaa82e9851064d22b954c3ebbafc9ae6.r2.dev/legacy/webp/grilled-meat-wrap-with-fresh-vegetables-and-fries-hwXO2VazvKWFcDsZwfo8W.webp",
      );
}

class SearchDish {
  final int id;
  final String name;
  final double price;
  final String category;
  final int restaurantId;
  final String restaurantName;
  final String? image;

  SearchDish({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.restaurantId,
    required this.restaurantName,
    this.image,
  });

  factory SearchDish.fromJson(Map<String, dynamic> j) => SearchDish(
        id: j['id'],
        name: j['name'],
        price: double.parse(j['price'].toString()),
        category: j['category'],
        restaurantId: j['restaurant']['id'],
        restaurantName: j['restaurant']['name'],
        image: j['image'] ??
            "https://pub-aaa82e9851064d22b954c3ebbafc9ae6.r2.dev/legacy/webp/grilled-meat-wrap-with-fresh-vegetables-and-fries-hwXO2VazvKWFcDsZwfo8W.webp",
      );
}

class SearchResult {
  final List<SearchRestaurant> restaurants;
  final List<SearchDish> dishes;

  SearchResult({required this.restaurants, required this.dishes});

  factory SearchResult.fromJson(Map<String, dynamic> j) => SearchResult(
        restaurants: (j['restaurants'] as List)
            .map((e) => SearchRestaurant.fromJson(e))
            .toList(),
        dishes:
            (j['dishes'] as List).map((e) => SearchDish.fromJson(e)).toList(),
      );

  bool get isEmpty => restaurants.isEmpty && dishes.isEmpty;
}
