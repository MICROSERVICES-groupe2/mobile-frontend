import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class UpdateProfilePictureUseCase {
  final AuthRepository repository;

  UpdateProfilePictureUseCase(this.repository);

  Future<Either<Failure, User>> execute(String imagePath) async {
    return await repository.updateProfilePicture(imagePath);
  }
}
