class CartData {
  final int? id;
  final int? restaurantId;
  final double? itemsTotal;
  final List<CartDataItem>? items;
  final double? deliveryFee;
  final double? platformFee;
  final double? estimatedTotal;
  final bool? isFreeDelivery;
  final double? freeDeliveryThreshold;

  CartData({
    this.id,
    this.restaurantId,
    this.itemsTotal,
    this.items,
    this.deliveryFee,
    this.platformFee,
    this.estimatedTotal,
    this.isFreeDelivery,
    this.freeDeliveryThreshold,
  });

  factory CartData.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final fee = data['fee_breakdown'];
    return CartData(
      id: data['id'],
      restaurantId: data['restaurant'],
      itemsTotal: double.parse(data['items_total'].toString()),
      items:
          (data['items'] as List).map((e) => CartDataItem.fromJson(e)).toList(),
      deliveryFee: (fee['delivery_fee'] as num).toDouble(),
      platformFee: (fee['platform_fee'] as num).toDouble(),
      estimatedTotal: (fee['estimated_total'] as num).toDouble(),
      isFreeDelivery: fee['is_free_delivery'],
      freeDeliveryThreshold: (fee['free_delivery_threshold'] as num).toDouble(),
    );
  }
}

class CartDataItem {
  final int? id; // cart item id (used for update/remove)
  final int? menuItemId;
  final String? itemName;
  final double? itemPrice;
  int? quantity;
  final double? subtotal;
  final String? image;

  CartDataItem({
    this.id,
    this.menuItemId,
    this.itemName,
    this.itemPrice,
    this.quantity,
    this.subtotal,
    this.image,
  });

  factory CartDataItem.fromJson(Map<String, dynamic> json) => CartDataItem(
        id: json['id'],
        menuItemId: json['menu_item'],
        itemName: json['item_name'],
        itemPrice: double.parse(json['item_price'].toString()),
        quantity: json['quantity'] ?? 0,
        subtotal: double.parse(json['subtotal'].toString()),
        image: json['image'],
      );
}
