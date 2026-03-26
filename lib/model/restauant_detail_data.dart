class MenuItem {
  final int id;
  final int restaurantId;
  final String name;
  final String description;
  final double price;
  final String category;
  final bool isAvailable;
  final String? image;

  MenuItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.isAvailable,
    this.image,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: json['id'],
        restaurantId: json['restaurant_id'],
        name: json['name'],
        description: json['description'] ?? '',
        price: double.parse(json['price'].toString()),
        category: json['category'],
        isAvailable: json['is_available'],
        image: json['image'],
      );
}

class CartItem {
  final int cartItemId;
  final MenuItem menuItem;
  int quantity;

  CartItem({
    required this.cartItemId,
    required this.menuItem,
    required this.quantity,
  });
}

class Restaurant {
  final int id;
  final String businessName;
  final String address;
  final String pincode;
  final bool isAcceptingOrders;
  final double baseFee;
  final double platformFee;
  final String restaurantImage;
  final double avgRating;
  final int totalRatings;
  final List<MenuItem> vegMenu;

  Restaurant({
    required this.id,
    required this.businessName,
    required this.address,
    required this.pincode,
    required this.isAcceptingOrders,
    required this.baseFee,
    required this.platformFee,
    required this.restaurantImage,
    required this.avgRating,
    required this.totalRatings,
    required this.vegMenu,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    // Flatten all menu items from all categories
    final List<MenuItem> allMenuItems = [];
    for (final menu in (data['menu'] as List)) {
      for (final item in (menu['menu_items'] as List)) {
        allMenuItems.add(MenuItem.fromJson(item['item_data']));
      }
    }

    return Restaurant(
      id: data['id'],
      businessName: data['business_name'],
      address: data['address'],
      pincode: data['pincode'],
      isAcceptingOrders: data['is_accepting_orders'],
      baseFee: (data['delivery_info']['base_fee'] as num).toDouble(),
      platformFee: (data['delivery_info']['platform_fee'] as num).toDouble(),
      restaurantImage: data['restaurantImage'] ??
          'https://lh3.googleusercontent.com/gps-cs-s/AHVAwepJq6ir47u82guAVTnYkHeVg8MuVUHxZ6Qrxvz58KqAEZiYlo6L9ZdXZsIrRNEnKnF2sxO5HckpbQkLqpSTOCszYxjC7fn_Z26E3zOIipqS91PvSiJj-YO-8rILHnm2A7umIkYPxQ=s1360-w1360-h1020-rw',
      avgRating: (data['ratings']['average'] as num).toDouble(),
      totalRatings: data['ratings']['total'],
      vegMenu: allMenuItems, // now contains ALL items (veg + non-veg)
    );
  }
}
