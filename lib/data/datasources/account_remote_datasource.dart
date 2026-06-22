import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../models/account_model.dart';

abstract class AccountRemoteDataSource {
  Future<List<AccountModel>> getAccounts({String? clientId});
  Future<AccountModel> getAccountDetail(String accountId);
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final DioClient dioClient;

  AccountRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<AccountModel>> getAccounts({String? clientId}) async {
    try {
      final path = clientId != null && clientId.isNotEmpty
          ? '${ApiConstants.accountsPath}/client/$clientId'
          : ApiConstants.accountsPath;
      final response = await dioClient.dio.get(path);
      final dynamic rawData = response.data;
      List<dynamic> data;
      if (rawData is List) {
        data = rawData;
      } else if (rawData is Map<String, dynamic>) {
        // Handle wrapped responses like {"data":[...]} or {"accounts":[...]} or {"count":0}
        if (rawData.containsKey('data') && rawData['data'] is List) {
          data = rawData['data'] as List<dynamic>;
        } else if (rawData.containsKey('accounts') && rawData['accounts'] is List) {
          data = rawData['accounts'] as List<dynamic>;
        } else {
          // e.g. {"count":0} — empty result
          data = [];
        }
      } else {
        data = [];
      }
      return data.map((json) => AccountModel.fromJson(json)).toList();
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
  Future<AccountModel> getAccountDetail(String accountId) async {
    try {
      final response = await dioClient.dio.get('${ApiConstants.accountsPath}/$accountId');
      return AccountModel.fromJson(response.data);
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
