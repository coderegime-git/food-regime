class NotificationData {
  int? statusCode;
  int? unreadCount;
  List<Data>? data;

  NotificationData({this.statusCode, this.unreadCount, this.data});

  NotificationData.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    unreadCount = json['unread_count'];
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
    data['unread_count'] = this.unreadCount;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? title;
  String? message;
  String? notificationType;
  bool? isRead;
  String? createdAt;

  Data(
      {this.id,
      this.title,
      this.message,
      this.notificationType,
      this.isRead,
      this.createdAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    message = json['message'];
    notificationType = json['notification_type'];
    isRead = json['is_read'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['message'] = this.message;
    data['notification_type'] = this.notificationType;
    data['is_read'] = this.isRead;
    data['created_at'] = this.createdAt;
    return data;
  }
}
