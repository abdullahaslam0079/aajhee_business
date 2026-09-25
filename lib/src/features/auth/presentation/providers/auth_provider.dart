import 'package:aajhee_business/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aajhee_business/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:aajhee_business/src/imports/core_imports.dart';
import 'package:aajhee_business/src/imports/packages_imports.dart';
import 'package:aajhee_business/src/routing/app_navigation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl();
}

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  bool build() => false;

  void login({
    required BuildContext context,
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    state = true;

    final result = await ref.read(authRepositoryProvider).login(
          email: email,
          password: password,
          rememberMe: rememberMe,
        );

    state = false;
    result.fold(
      (failure) =>
          showToast(context, message: failure.message, status: 'error'),
      (_) {
        if (rootContext?.mounted ?? false) {
          navigateAfterAuthentication(rootContext!);
        }
      },
    );
  }

  void signUp({
    required BuildContext context,
    required String name,
    required String email,
    required String password,
    required String passwordConfirm,
    required int categoryId,
  }) async {
    state = true;

    final result = await ref.read(authRepositoryProvider).signUp(
          name: name,
          email: email,
          password: password,
          passwordConfirm: passwordConfirm,
          categoryId: categoryId,
        );

    state = false;
    result.fold(
      (failure) =>
          showToast(context, message: failure.message, status: 'error'),
      (_) {
        if (rootContext?.mounted ?? false) {
          navigateAfterAuthentication(rootContext!);
        }
      },
    );
  }
}
