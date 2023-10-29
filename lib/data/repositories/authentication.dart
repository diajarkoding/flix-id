import 'package:flix_id/domain/entities/result.dart';
import 'package:flix_id/domain/entities/user.dart';

abstract interface class Authentication {
  Future<Result<String>> register(
      {required String email, required String password});
  Future<Result<User>> login({required String email, required String password});
  Future<Result<void>> logout();
  String? getLoggedInUserToken();
}
