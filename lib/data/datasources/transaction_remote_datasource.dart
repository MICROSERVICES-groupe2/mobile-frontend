import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getTransactions({
    String? accountId,
    String? type,
    int? limit,
    int? offset,
  });
  Future<void> createTransfer(String sourceAccountId, String destinationAccountId, double montant, String devise);
  Future<void> createDeposit(String accountId, double montant, String devise);
  Future<void> createWithdrawal(String accountId, double montant, String devise);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final DioClient dioClient;

  TransactionRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<TransactionModel>> getTransactions({
    String? accountId,
    String? type,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (accountId != null) queryParams['accountId'] = accountId;
      if (type != null) queryParams['type'] = type;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await dioClient.dio.get(
        ApiConstants.transactionsPath,
        queryParameters: queryParams,
      );

      // The API may return either a raw list or an object containing the list under a specific key (e.g., "data" or "transactions").
      final dynamic rawData = response.data;
      List<dynamic> data;
      if (rawData is List) {
        data = rawData;
      } else if (rawData is Map<String, dynamic>) {
        // Try common keys that may hold the transaction list.
        if (rawData.containsKey('transactions')) {
          data = rawData['transactions'] as List<dynamic>;
        } else if (rawData.containsKey('data')) {
          data = rawData['data'] as List<dynamic>;
        } else {
          // Fallback: treat the whole map as a single transaction entry.
          data = [rawData];
        }
      } else {
        // Unexpected format; throw to be caught by outer handler.
        throw ServerException('Unexpected response format');
      }
      return data.map((json) => TransactionModel.fromJson(json)).toList();
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
  Future<void> createTransfer(String sourceAccountId, String destinationAccountId, double montant, String devise) async {
    try {
      await dioClient.dio.post(
        '${ApiConstants.transactionsPath}/transfer',
        data: {
          'sourceAccountId': sourceAccountId,
          'destinationAccountId': destinationAccountId,
          'montant': montant,
          'devise': devise,
          'operatorId': 'WAVE',
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.response?.data?['message'] ?? e.response?.data?['error'] ?? e.message ?? 'Erreur lors du transfert');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> createDeposit(String accountId, double montant, String devise) async {
    try {
      await dioClient.dio.post(
        '${ApiConstants.transactionsPath}/deposit',
        data: {
          'accountId': accountId,
          'montant': montant,
          'devise': devise,
          'operatorId': 'WAVE',
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.response?.data?['message'] ?? e.response?.data?['error'] ?? e.message ?? 'Erreur lors du dépôt');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> createWithdrawal(String accountId, double montant, String devise) async {
    try {
      await dioClient.dio.post(
        '${ApiConstants.transactionsPath}/withdraw',
        data: {
          'accountId': accountId,
          'montant': montant,
          'devise': devise,
          'operatorId': 'WAVE',
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.response?.data?['message'] ?? e.response?.data?['error'] ?? e.message ?? 'Erreur lors du retrait');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
