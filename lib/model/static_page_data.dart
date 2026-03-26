class StaticPageData {
  int? statusCode;
  List<Data>? data;

  StaticPageData({this.statusCode, this.data});

  StaticPageData.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? title;
  String? pageType;
  String? role;
  String? content;
  bool? isActive;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.id,
      this.title,
      this.pageType,
      this.role,
      this.content,
      this.isActive,
      this.createdAt,
      this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    pageType = json['page_type'];
    role = json['role'];
    content = json['content'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['page_type'] = this.pageType;
    data['role'] = this.role;
    data['content'] = this.content;
    data['is_active'] = this.isActive;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
