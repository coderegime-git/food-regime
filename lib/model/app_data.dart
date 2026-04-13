class AppUpdateData {
  int? statusCode;
  String? message;
  Data? data;

  AppUpdateData({this.statusCode, this.message, this.data});

  AppUpdateData.fromJson(Map<String, dynamic> json) {
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
  String? platform;
  String? role;
  int? versionCode;
  String? versionName;
  bool? isForceUpdate;
  bool? needUpdate;
  String? updateUrl;
  String? updateMessage;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.id,
      this.platform,
      this.role,
      this.versionCode,
      this.versionName,
      this.isForceUpdate,
      this.needUpdate,
      this.updateUrl,
      this.updateMessage,
      this.createdAt,
      this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    platform = json['platform'];
    role = json['role'];
    versionCode = json['version_code'];
    versionName = json['version_name'];
    isForceUpdate = json['is_force_update'];
    needUpdate = json['is_update'] ?? false;
    updateUrl = json['update_url'];
    updateMessage = json['update_message'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['platform'] = this.platform;
    data['role'] = this.role;
    data['version_code'] = this.versionCode;
    data['version_name'] = this.versionName;
    data['is_force_update'] = this.isForceUpdate;
    data['update_url'] = this.updateUrl;
    data['update_message'] = this.updateMessage;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
