import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/notification.dart';
import '../../repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;
  GetNotificationsUseCase(this.repository);

  Future<Either<Failure, List<AppNotification>>> execute({String? userId}) async {
    return await repository.getNotifications(userId: userId);
  }
}

class MarkNotificationReadUseCase {
  final NotificationRepository repository;
  MarkNotificationReadUseCase(this.repository);

  Future<Either<Failure, void>> execute(String notificationId) async {
    return await repository.markAsRead(notificationId);
  }
}

class GetUnreadCountUseCase {
  final NotificationRepository repository;
  GetUnreadCountUseCase(this.repository);

  Future<Either<Failure, int>> execute({String? userId}) async {
    return await repository.getUnreadCount(userId: userId);
  }
}
