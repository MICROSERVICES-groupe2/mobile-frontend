import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../models/affiliated_operator_model.dart';
import '../models/client_model.dart';
import '../models/kyc_document_model.dart';

abstract class ClientRemoteDataSource {
  Future<ClientModel> createClient(ClientModel client);
  Future<ClientModel> getClient(String clientId);
  Future<ClientModel> updateClient(String clientId, ClientModel client);
  Future<List<KycDocumentModel>> getKycDocuments(String clientId);
  Future<KycDocumentModel> uploadKycDocument(String clientId, String type, String filePath, {String? commentaire});
  Future<AffiliatedOperatorModel> createAffiliation(String clientId, String operatorCode, String operatorAccountId);
  Future<List<AffiliatedOperatorModel>> getAffiliations(String clientId);
}

class ClientRemoteDataSourceImpl implements ClientRemoteDataSource {
  final DioClient dioClient;

  ClientRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<ClientModel> createClient(ClientModel client) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.clientsPath,
        data: client.toJson()..remove('id'),
      );
      return ClientModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.response?.data?['message'] ?? e.message ?? 'Erreur serveur');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ClientModel> getClient(String clientId) async {
    try {
      final response = await dioClient.dio.get('$ApiConstants.clientsPath/$clientId');
      return ClientModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.response?.data?['message'] ?? e.message ?? 'Erreur serveur');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ClientModel> updateClient(String clientId, ClientModel client) async {
    try {
      final response = await dioClient.dio.put(
        '$ApiConstants.clientsPath/$clientId',
        data: client.toJson()..remove('id'),
      );
      return ClientModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.response?.data?['message'] ?? e.message ?? 'Erreur serveur');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<KycDocumentModel>> getKycDocuments(String clientId) async {
    try {
      final response = await dioClient.dio.get('$ApiConstants.clientsPath/$clientId/kyc-documents');
      final List<dynamic> data = response.data;
      return data.map((json) => KycDocumentModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.response?.data?['message'] ?? e.message ?? 'Erreur serveur');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<KycDocumentModel> uploadKycDocument(String clientId, String type, String filePath, {String? commentaire}) async {
    try {
      final formData = FormData.fromMap({
        'type': type,
        if (commentaire != null) 'commentaire': commentaire,
        'file': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final response = await dioClient.dio.post(
        '$ApiConstants.clientsPath/$clientId/kyc-documents',
        data: formData,
      );
      return KycDocumentModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.response?.data?['message'] ?? e.message ?? 'Erreur serveur');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AffiliatedOperatorModel> createAffiliation(String clientId, String operatorCode, String operatorAccountId) async {
    try {
      final response = await dioClient.dio.post(
        '$ApiConstants.clientsPath/$clientId/affiliate',
        data: {
          'operatorCode': operatorCode,
          'operatorAccountId': operatorAccountId,
        },
      );
      return AffiliatedOperatorModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.response?.data?['message'] ?? e.message ?? 'Erreur serveur');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<AffiliatedOperatorModel>> getAffiliations(String clientId) async {
    try {
      final response = await dioClient.dio.get('$ApiConstants.clientsPath/$clientId/affiliations');
      final List<dynamic> data = response.data;
      return data.map((json) => AffiliatedOperatorModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.response?.data?['message'] ?? e.message ?? 'Erreur serveur');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
