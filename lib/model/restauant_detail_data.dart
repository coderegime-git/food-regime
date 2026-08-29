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
  final String distance;
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
    required this.distance,
    required this.vegMenu,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    // Flatten all menu items from all categories
    final List<MenuItem> allMenuItems = [];
    if (data['menu'] != null) {
      for (final menu in (data['menu'] as List)) {
        if (menu['menu_items'] != null) {
          for (final item in (menu['menu_items'] as List)) {
            if (item['item_data'] != null) {
              allMenuItems.add(MenuItem.fromJson(item['item_data']));
            }
          }
        }
      }
    }

    final img = (data['image'] ?? data['restaurantImage'])?.toString().trim();
    final parsedImage = (img == null || img.isEmpty || img == 'null' || !img.startsWith('http'))
        ? 'https://lh3.googleusercontent.com/gps-cs-s/AHVAwepJq6ir47u82guAVTnYkHeVg8MuVUHxZ6Qrxvz58KqAEZiYlo6L9ZdXZsIrRNEnKnF2sxO5HckpbQkLqpSTOCszYxjC7fn_Z26E3zOIipqS91PvSiJj-YO-8rILHnm2A7umIkYPxQ=s1360-w1360-h1020-rw'
        : img;

    final baseFee = data['delivery_fee'] ?? 
        data['deliveryFee'] ?? 
        (data['delivery_info'] != null ? data['delivery_info']['base_fee'] : 0) ?? 
        0;
        
    final platformFee = data['platform_fee'] ??
        (data['delivery_info'] != null ? data['delivery_info']['platform_fee'] : 0) ?? 
        0;

    return Restaurant(
      id: data['id'] ?? 0,
      businessName: data['business_name'] ?? data['name'] ?? '',
      address: data['address'] ?? '',
      pincode: data['pincode'] ?? '',
      isAcceptingOrders: data['is_accepting_orders'] ?? true,
      baseFee: double.tryParse(baseFee.toString()) ?? 0,
      platformFee: double.tryParse(platformFee.toString()) ?? 0,
      restaurantImage: parsedImage,
      avgRating: double.tryParse((data['rating']?['average'] ?? data['ratings']?['average'] ?? 0).toString()) ?? 0,
      totalRatings: data['rating']?['count'] ?? data['ratings']?['total'] ?? 0,
      distance: data['delivery_time']?.toString() ?? data['distance']?.toString() ?? '0',
      vegMenu: allMenuItems, // now contains ALL items (veg + non-veg)
    );
  }
}
