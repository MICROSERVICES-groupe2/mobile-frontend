import 'package:dartz/dartz.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failures.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AppNotification>>> getNotifications({String? userId}) async {
    try {
      final notifications = await remoteDataSource.getNotifications(userId: userId);
      return Right(notifications);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Non autorisé.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Erreur inattendue.'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await remoteDataSource.markAsRead(notificationId);
      return const Right(null);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Non autorisé.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Erreur inattendue.'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount({String? userId}) async {
    try {
      final count = await remoteDataSource.getUnreadCount(userId: userId);
      return Right(count);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Non autorisé.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Erreur inattendue.'));
    }
  }
}
