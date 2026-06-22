import '../../domain/entities/notification.dart';

class NotificationModel extends AppNotification {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.type,
    required super.isRead,
    required super.timestamp,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'INFO',
      isRead: json['isRead'] ?? false,
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
    );
  }
}
