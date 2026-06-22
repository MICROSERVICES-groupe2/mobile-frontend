import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../models/loan_model.dart';

abstract class LoanRemoteDataSource {
  Future<List<LoanModel>> getLoans();
  Future<LoanModel> simulateLoan(double montant, int dureeMois);
  Future<void> requestLoan(double montant, int dureeMois, String accountId);
}

class LoanRemoteDataSourceImpl implements LoanRemoteDataSource {
  final DioClient dioClient;

  LoanRemoteDataSourceImpl({required this.dioClient});

  String get _loansBase => ApiConstants.loansPath;

  @override
  Future<List<LoanModel>> getLoans() async {
    try {
      final response = await dioClient.dio.get(_loansBase);
      final List<dynamic> data = response.data;
      return data.map((json) => LoanModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.message ?? 'Erreur serveur');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<LoanModel> simulateLoan(double montant, int dureeMois) async {
    try {
      String path = ApiConstants.loansPath.endsWith('/')
          ? '${ApiConstants.loansPath}simulate'
          : '${ApiConstants.loansPath}/simulate';
      final response = await dioClient.dio.post(
        path,
        data: {'montant': montant, 'dureeMois': dureeMois},
      );
      return LoanModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.message ?? 'Erreur serveur');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> requestLoan(double montant, int dureeMois, String accountId) async {
    try {
      await dioClient.dio.post(
        _loansBase,
        data: {'montant': montant, 'dureeMois': dureeMois, 'accountId': accountId},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.response?.data?['error'] ?? e.message ?? 'Erreur serveur');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
