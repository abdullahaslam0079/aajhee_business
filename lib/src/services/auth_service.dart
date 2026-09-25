import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:aajhee_business/src/config/app_config.dart';
import 'package:aajhee_business/src/services/auth_token_service.dart';
import 'package:aajhee_business/src/utils/utils.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  Dio get _dio => AppConfig.dio;
  final _authStateController =
      StreamController<Map<String, dynamic>?>.broadcast();

  Stream<Map<String, dynamic>?> get authStateChanges =>
      _authStateController.stream;

  FutureEither<Map<String, dynamic>?> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    return runTask(() async {
      final response = await _dio.post(
        '/business/auth/token',
        data: {'email': email.trim(), 'password': password},
      );
      final data = response.data as Map<String, dynamic>;
      final access = data['access'] as String?;
      final business = data['business'] as Map<String, dynamic>?;
      if (access == null || business == null) {
        throw Exception('Invalid login response from server.');
      }
      await _persistSession(
        accessToken: access,
        business: business,
        persist: rememberMe,
      );
      final userData = _mapBusinessToUser(business);
      _authStateController.add(userData);
      return userData;
    }, requiresNetwork: true);
  }

  FutureEither<Map<String, dynamic>?> signUp({
    required String name,
    required String email,
    required String password,
    required String passwordConfirm,
    required int categoryId,
  }) async {
    final registerResult = await runTask(() async {
      await _dio.post(
        '/business/auth/register',
        data: {
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
          'password_confirm': passwordConfirm,
          'category_id': categoryId,
        },
      );
      return true;
    }, requiresNetwork: true);

    return registerResult.fold(
      (failure) => Future.value(left(failure)),
      (_) => login(email: email, password: password),
    );
  }

  FutureEither<List<Map<String, dynamic>>> getCategories() async {
    return runTask(() async {
      final response = await _dio.get('/categories');
      final list = response.data as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    }, requiresNetwork: true);
  }

  FutureEither<void> forgotPassword({required String email}) async {
    return runTask(() async {
      await _dio.post(
        '/auth/password/forgot',
        data: {'email': email.trim()},
      );
    }, requiresNetwork: true);
  }

  FutureEither<void> logout() async {
    return runTask(() async {
      await AuthTokenService.instance.clearSession();
      _authStateController.add(null);
    });
  }

  FutureEither<Map<String, dynamic>?> getCurrentUser() async {
    return runTask(() async {
      final tokenResult = await AuthTokenService.instance.getAccessToken();
      final token = tokenResult.getOrElse((_) => null);
      if (token == null || token.isEmpty) return null;

      final cachedResult = await AuthTokenService.instance.getCachedBusiness();
      final cachedBusiness = cachedResult.getOrElse((_) => null);

      try {
        final response = await _dio.get('/business/profile');
        final business = response.data as Map<String, dynamic>;
        await _persistSession(
          accessToken: token,
          business: business,
        );
        return _mapBusinessToUser(business);
      } on DioException catch (e) {
        if (e.response?.statusCode == 401) {
          await AuthTokenService.instance.clearSession();
          return null;
        }
        if (cachedBusiness != null) {
          return _mapBusinessToUser(cachedBusiness);
        }
        rethrow;
      }
    });
  }

  Future<void> _persistSession({
    required String accessToken,
    required Map<String, dynamic> business,
    bool persist = true,
  }) async {
    final saveResult = await AuthTokenService.instance.saveSession(
      accessToken: accessToken,
      business: business,
      persist: persist,
    );
    saveResult.fold(
      (failure) => throw Exception(failure.message),
      (_) {},
    );
  }

  Map<String, dynamic> _mapBusinessToUser(Map<String, dynamic> business) {
    return {
      'id': business['id'].toString(),
      'email': business['email'] ?? '',
      'name': business['name'],
      'photoUrl': business['logo_url'],
    };
  }

  void dispose() {
    _authStateController.close();
  }
}
