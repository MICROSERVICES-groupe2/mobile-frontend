import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({String? userId});
  Future<void> markAsRead(String notificationId);
  Future<int> getUnreadCount({String? userId});
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final DioClient dioClient;

  NotificationRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<NotificationModel>> getNotifications({String? userId}) async {
    try {
      final query = userId != null && userId.isNotEmpty ? {'userId': userId} : <String, dynamic>{};
      final response = await dioClient.dio.get(
        ApiConstants.notificationsPath,
        queryParameters: query.isEmpty ? null : query,
      );
      final List<dynamic> data = response.data;
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.message ?? 'Erreur serveur');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await dioClient.dio.put(
        '${ApiConstants.notificationsPath}/$notificationId/read',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.message ?? 'Erreur serveur');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<int> getUnreadCount({String? userId}) async {
    try {
      final query = userId != null && userId.isNotEmpty ? {'userId': userId} : <String, dynamic>{};
      final response = await dioClient.dio.get(
        '${ApiConstants.notificationsPath}/unread-count',
        queryParameters: query.isEmpty ? null : query,
      );
      return response.data['count'] ?? 0;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.message ?? 'Erreur serveur');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
