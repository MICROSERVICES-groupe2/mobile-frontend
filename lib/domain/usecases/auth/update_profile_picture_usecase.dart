import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class UpdateProfilePictureUseCase {
  final AuthRepository repository;

  UpdateProfilePictureUseCase(this.repository);

  Future<Either<Failure, User>> execute(Uint8List bytes, String mimeType) async {
    return await repository.updateProfilePicture(bytes, mimeType);
  }
}
