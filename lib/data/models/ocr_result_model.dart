import '../../domain/entities/ocr_result.dart';

class OcrResultModel extends OcrResult {
  const OcrResultModel({
    required super.status,
    super.documentId,
    required super.parsedData,
  });

  factory OcrResultModel.fromJson(Map<String, dynamic> json) {
    final parsed = json['parsed_data'] ?? json['parsedData'] ?? {};
    return OcrResultModel(
      status: json['status'] ?? '',
      documentId: json['document_id'] ?? json['documentId'],
      parsedData: OcrParsedDataModel.fromJson(parsed),
    );
  }
}

class OcrParsedDataModel extends OcrParsedData {
  const OcrParsedDataModel({
    super.nom,
    super.prenom,
    super.numeroId,
    super.dateNaissance,
    super.revenus,
    super.employeur,
    super.confidence,
  });

  factory OcrParsedDataModel.fromJson(Map<String, dynamic> json) {
    return OcrParsedDataModel(
      nom: json['nom'],
      prenom: json['prenom'],
      numeroId: json['numeroId'],
      dateNaissance: json['dateNaissance'],
      revenus: json['revenus'] != null ? (json['revenus'] as num).toDouble() : null,
      employeur: json['employeur'],
      confidence: json['confidence'] != null ? (json['confidence'] as num).toDouble() : null,
    );
  }
}

class CreditScoreModel extends CreditScore {
  const CreditScoreModel({
    required super.score,
    required super.decision,
    required super.factors,
  });

  factory CreditScoreModel.fromJson(Map<String, dynamic> json) {
    return CreditScoreModel(
      score: json['score'] ?? 0,
      decision: json['decision'] ?? '',
      factors: (json['factors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
