import 'package:goluto_business/src/features/auth/domain/entities/user.dart';
import 'package:goluto_business/src/utils/utils.dart';

abstract class AuthRepository {
  Stream<AppUser?> get onAuthStateChanged;

  FutureEither<AppUser> login({
    required String email,
    required String password,
    bool rememberMe = true,
  });

  FutureEither<AppUser> signUp({
    required String name,
    required String email,
    required String password,
    required String passwordConfirm,
    required int categoryId,
  });

  FutureEither<List<Map<String, dynamic>>> getCategories();

  FutureEither<void> forgotPassword({required String email});

  FutureEither<void> logout();

  FutureEither<AppUser?> checkAuthState();
}
