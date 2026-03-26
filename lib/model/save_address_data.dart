// SavedAddressData savedAddressDataFromJson(Map<String, dynamic> json) =>
//     SavedAddressData.fromJson(json);

class AddressModel {
  final int? id;
  final String addressType;
  final String fullAddress;
  final String landmark;
  final String pincode;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final String? createdAt;

  AddressModel({
    this.id,
    required this.addressType,
    required this.fullAddress,
    required this.landmark,
    required this.pincode,
    this.latitude,
    this.longitude,
    required this.isDefault,
    this.createdAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        id: json['id'],
        addressType: json['address_type'] ?? 'home',
        fullAddress: json['full_address'] ?? '',
        landmark: json['landmark'] ?? '',
        pincode: json['pincode'] ?? '',
        latitude: json['latitude'] != null
            ? double.tryParse(json['latitude'].toString())
            : null,
        longitude: json['longitude'] != null
            ? double.tryParse(json['longitude'].toString())
            : null,
        isDefault: json['is_default'] ?? false,
        createdAt: json['created_at'],
      );

  Map<String, dynamic> toJson() => {
        'address_type': addressType,
        'full_address': fullAddress,
        'landmark': landmark,
        'pincode': pincode,
        'latitude': latitude,
        // hardcoded for now, dynamic once map integrated
        'longitude': longitude,
        // hardcoded for now, dynamic once map integrated
        'is_default': isDefault,
      };

  AddressModel copyWith({
    int? id,
    String? addressType,
    String? fullAddress,
    String? landmark,
    String? pincode,
    double? latitude,
    double? longitude,
    bool? isDefault,
    String? createdAt,
  }) =>
      AddressModel(
        id: id ?? this.id,
        addressType: addressType ?? this.addressType,
        fullAddress: fullAddress ?? this.fullAddress,
        landmark: landmark ?? this.landmark,
        pincode: pincode ?? this.pincode,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        isDefault: isDefault ?? this.isDefault,
        createdAt: createdAt ?? this.createdAt,
      );
}
