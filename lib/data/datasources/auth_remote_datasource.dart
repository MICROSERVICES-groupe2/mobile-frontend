import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';

import '../../../core/errors/exceptions.dart';
import '../../../core/network/dio_client.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(
    String email,
    String password, {
    String? totpCode,
  });
  Future<Map<String, dynamic>> register(
    String firstName,
    String lastName,
    String email,
    String password,
    String phone,
  );
  Future<Map<String, dynamic>> verifyRegistrationOtp(String userId, String code);
  Future<Map<String, dynamic>> verify2FA(String code);
  Future<Map<String, dynamic>> loginWithBiometrics(String token);
  Future<Map<String, dynamic>> updateProfilePicture(Uint8List bytes, String mimeType);
  Future<void> sendFcmToken(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<Map<String, dynamic>> login(
    String email,
    String password, {
    String? totpCode,
  }) async {
    try {
      final response = await dioClient.dio.post(
          '${ApiConstants.authPath}/login',
          data: {
            'email': email,
            'password': password,
            if (totpCode != null && totpCode.isNotEmpty) 'totpCode': totpCode,
          },
        );

      return response.data;
    } on DioException catch (e) {
      // Extract server-provided error message if available
      final serverMessage = e.response?.data is Map && e.response?.data['message'] != null
          ? e.response?.data['message'] as String
          : null;
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      if (e.response?.statusCode == 403) {
        final error = e.response?.data?['error'];
        if (error == 'TWO_FA_REQUIRED') {
          throw TwoFARequiredException(email);
        }
      }
      // Throw with server message when present, otherwise generic
      throw ServerException(serverMessage ?? e.message ?? 'Unknown Error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> register(
    String firstName,
    String lastName,
    String email,
    String password,
    String phone,
  ) async {
    try {
      final response = await dioClient.dio.post(
        '${ApiConstants.authPath}/register',
        data: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'phone': phone,
        }),
        options: Options(contentType: Headers.jsonContentType),
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ServerException(e.response?.data?['message'] ?? 'Données invalides.');
      }
      if (e.response?.statusCode == 409) {
        throw ServerException('Un compte existe déjà avec cet email.');
      }
      throw ServerException(e.message ?? 'Unknown Error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> verifyRegistrationOtp(String userId, String code) async {
    try {
      final response = await dioClient.dio.post(
        '${ApiConstants.authPath}/verify-registration-otp',
        data: {'userId': userId, 'code': code},
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(e.response?.data?['message'] ?? e.message ?? 'Unknown Error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> verify2FA(String code) async {
    try {
      final response = await dioClient.dio.post(
        '${ApiConstants.authPath}/verify-2fa',
        data: {'code': code},
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(e.message ?? 'Unknown Error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> loginWithBiometrics(String token) async {
    try {
      final response = await dioClient.dio.post(
        '${ApiConstants.authPath}/biometric',
        data: {'biometricToken': token},
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(e.message ?? 'Unknown Error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> updateProfilePicture(Uint8List bytes, String mimeType) async {
    try {
      final base64Image = base64Encode(bytes);
      final dataUri = 'data:$mimeType;base64,$base64Image';

      final response = await dioClient.dio.post(
        '${ApiConstants.authPath}/avatar',
        data: {'avatarUrl': dataUri},
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(e.message ?? 'Unknown Error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> sendFcmToken(String token) async {
    try {
      await dioClient.dio.post(
        '${ApiConstants.authPath}/fcm-token',
        data: {'fcmToken': token},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(e.message ?? 'Unknown Error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
