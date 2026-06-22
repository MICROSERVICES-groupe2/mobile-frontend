import 'package:equatable/equatable.dart';

class KycDocument extends Equatable {
  final String id;
  final String type;
  final String urlFichier;
  final String statutValidation;
  final DateTime? dateUpload;
  final DateTime? dateValidation;
  final String? commentaire;

  const KycDocument({
    required this.id,
    required this.type,
    required this.urlFichier,
    required this.statutValidation,
    this.dateUpload,
    this.dateValidation,
    this.commentaire,
  });

  @override
  List<Object?> get props => [id, type, urlFichier, statutValidation, dateUpload, dateValidation, commentaire];
}
