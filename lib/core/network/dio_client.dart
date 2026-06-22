import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage.dart';

class DioClient {
  late final Dio _dio;
  final SecureStorage _secureStorage;

  DioClient({required SecureStorage secureStorage}) : _secureStorage = secureStorage {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectionTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        debugPrint('--- DIO REQUEST ---');
        debugPrint('Method: ${options.method}');
        debugPrint('URL: ${options.baseUrl}${options.path}');
        debugPrint('Headers: ${options.headers}');
        debugPrint('Data: ${options.data}');
        debugPrint('-------------------');
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Token expired, attempt refresh
          final refreshToken = await _secureStorage.getRefreshToken();
          if (refreshToken != null && refreshToken.isNotEmpty) {
            try {
              final refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
              final response = await refreshDio.post(
                '${ApiConstants.authPath}/refresh',
                data: {'refreshToken': refreshToken},
              );
              if (response.statusCode == 200) {
                final newAccessToken = response.data['accessToken'];
                await _secureStorage.saveToken(newAccessToken);
                if (response.data['refreshToken'] != null) {
                  await _secureStorage.saveRefreshToken(response.data['refreshToken']);
                }
                
                // Retry original request
                final opts = e.requestOptions;
                opts.headers['Authorization'] = 'Bearer $newAccessToken';
                final cloneReq = await _dio.fetch(opts);
                return handler.resolve(cloneReq);
              }
            } catch (_) {
              // Refresh failed, logout user (clear tokens)
              await _secureStorage.clearAll();
            }
          } else {
             await _secureStorage.clearAll();
          }
        }
        return handler.next(e);
      },
    ));

    // Optional log interceptor
    _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }

  Dio get dio => _dio;
}
