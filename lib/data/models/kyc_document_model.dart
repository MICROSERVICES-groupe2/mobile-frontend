import '../../domain/entities/kyc_document.dart';

class KycDocumentModel extends KycDocument {
  const KycDocumentModel({
    required super.id,
    required super.type,
    required super.urlFichier,
    required super.statutValidation,
    super.dateUpload,
    super.dateValidation,
    super.commentaire,
  });

  factory KycDocumentModel.fromJson(Map<String, dynamic> json) {
    return KycDocumentModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      urlFichier: json['urlFichier'] ?? '',
      statutValidation: json['statutValidation'] ?? 'PENDING',
      dateUpload: json['dateUpload'] != null ? DateTime.tryParse(json['dateUpload']) : null,
      dateValidation: json['dateValidation'] != null ? DateTime.tryParse(json['dateValidation']) : null,
      commentaire: json['commentaire'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'urlFichier': urlFichier,
      'statutValidation': statutValidation,
      'dateUpload': dateUpload?.toIso8601String(),
      'dateValidation': dateValidation?.toIso8601String(),
      'commentaire': commentaire,
    };
  }
}
