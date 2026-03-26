ProfileData profileDataFromJson(Map<String, dynamic> data) =>
    ProfileData.fromJson(data);

class ProfileData {
  int? statusCode;
  String? message;
  Data? data;

  ProfileData({this.statusCode, this.message, this.data});

  ProfileData.fromJson(Map<String, dynamic> json) {
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
  String? name;
  String? phone;
  String? dateOfBirth;
  String? gender;
  bool? isVeg;
  String? spiceLevel;
  String? walletBalance;
  int? loyaltyPoints;
  bool? isOnboardingComplete;
  DefaultAddress? defaultAddress;
  Null? cluster;

  Data(
      {this.name,
      this.phone,
      this.dateOfBirth,
      this.gender,
      this.isVeg,
      this.spiceLevel,
      this.walletBalance,
      this.loyaltyPoints,
      this.isOnboardingComplete,
      this.defaultAddress,
      this.cluster});

  Data.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    phone = json['phone'];
    dateOfBirth = json['date_of_birth'];
    gender = json['gender'];
    isVeg = json['is_veg'];
    spiceLevel = json['spice_level'];
    walletBalance = json['wallet_balance'];
    loyaltyPoints = json['loyalty_points'];
    isOnboardingComplete = json['is_onboarding_complete'];
    defaultAddress = json['default_address'] != null
        ? new DefaultAddress.fromJson(json['default_address'])
        : null;
    cluster = json['cluster'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['phone'] = this.phone;
    data['date_of_birth'] = this.dateOfBirth;
    data['gender'] = this.gender;
    data['is_veg'] = this.isVeg;
    data['spice_level'] = this.spiceLevel;
    data['wallet_balance'] = this.walletBalance;
    data['loyalty_points'] = this.loyaltyPoints;
    data['is_onboarding_complete'] = this.isOnboardingComplete;
    if (this.defaultAddress != null) {
      data['default_address'] = this.defaultAddress!.toJson();
    }
    data['cluster'] = this.cluster;
    return data;
  }
}

class DefaultAddress {
  int? id;
  String? addressType;
  String? fullAddress;
  String? landmark;
  String? pincode;
  double? latitude;
  double? longitude;

  DefaultAddress(
      {this.id,
      this.addressType,
      this.fullAddress,
      this.landmark,
      this.pincode,
      this.latitude,
      this.longitude});

  DefaultAddress.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    addressType = json['address_type'];
    fullAddress = json['full_address'];
    landmark = json['landmark'];
    pincode = json['pincode'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['address_type'] = this.addressType;
    data['full_address'] = this.fullAddress;
    data['landmark'] = this.landmark;
    data['pincode'] = this.pincode;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    return data;
  }
}
