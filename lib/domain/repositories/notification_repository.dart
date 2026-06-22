import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../entities/notification.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<AppNotification>>> getNotifications({String? userId});
  Future<Either<Failure, void>> markAsRead(String notificationId);
  Future<Either<Failure, int>> getUnreadCount({String? userId});
}
