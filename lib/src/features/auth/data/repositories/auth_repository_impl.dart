import 'package:aajhee_business/src/imports/core_imports.dart';
import 'package:aajhee_business/src/imports/packages_imports.dart';

import 'package:aajhee_business/src/features/auth/domain/entities/user.dart';
import 'package:aajhee_business/src/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService = AuthService.instance;

  @override
  Stream<AppUser?> get onAuthStateChanged {
    return _authService.authStateChanges.map((userData) {
      if (userData == null) return null;
      return _mapUser(userData);
    });
  }

  @override
  FutureEither<AppUser> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    final result = await _authService.login(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );

    return result.flatMap((userData) {
      if (userData == null) {
        return left(const ServerFailure('Login failed: User record not found'));
      }
      return right(_mapUser(userData));
    });
  }

  @override
  FutureEither<AppUser> signUp({
    required String name,
    required String email,
    required String password,
    required String passwordConfirm,
    required int categoryId,
  }) async {
    final result = await _authService.signUp(
      name: name,
      email: email,
      password: password,
      passwordConfirm: passwordConfirm,
      categoryId: categoryId,
    );

    return result.flatMap((userData) {
      if (userData == null) {
        return left(const ServerFailure('Sign up failed: User record corrupted'));
      }
      return right(_mapUser(userData));
    });
  }

  @override
  FutureEither<List<Map<String, dynamic>>> getCategories() {
    return _authService.getCategories();
  }

  @override
  FutureEither<void> forgotPassword({required String email}) {
    return _authService.forgotPassword(email: email);
  }

  @override
  FutureEither<void> logout() {
    return _authService.logout();
  }

  @override
  FutureEither<AppUser?> checkAuthState() async {
    final result = await _authService.getCurrentUser();

    return result.map((userData) {
      if (userData == null) return null;
      return _mapUser(userData);
    });
  }

  AppUser _mapUser(Map<String, dynamic> data) {
    return AppUser(
      id: data['id'].toString(),
      email: data['email'] ?? '',
      name: data['name'],
      photoUrl: data['photoUrl'],
    );
  }
}
