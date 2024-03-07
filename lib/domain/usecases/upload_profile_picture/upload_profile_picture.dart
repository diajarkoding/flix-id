import 'package:flix_id/domain/entities/result.dart';
import 'package:flix_id/domain/usecases/upload_profile_picture/upload_profile_picture_param.dart';
import 'package:flix_id/domain/usecases/usecase.dart';

import '../../../data/repositories/user_repository.dart';
import '../../entities/user.dart';

class UploadProfilePicture
    implements UseCase<Result<User>, UploadProfilePictureParam> {
  final UserRepository _userRepository;

  UploadProfilePicture({required UserRepository userRepository})
      : _userRepository = userRepository;

  @override
  Future<Result<User>> call(UploadProfilePictureParam params) => _userRepository
      .uploadProfilePicture(imageFile: params.imageFile, user: params.user);
}
