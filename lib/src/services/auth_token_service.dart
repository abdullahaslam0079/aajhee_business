import 'dart:convert';

import 'package:fpdart/fpdart.dart';

import 'package:goluto_business/src/services/secure_storage_service.dart';
import 'package:goluto_business/src/utils/utils.dart';

/// Persists JWT access tokens and cached business profile for session restore.
class AuthTokenService {
  AuthTokenService._();

  static final AuthTokenService instance = AuthTokenService._();

  static const _accessTokenKey = 'access_token';
  static const _businessProfileKey = 'business_profile';

  final _storage = SecureStorageService.instance;
  String? _memoryAccessToken;
  Map<String, dynamic>? _memoryBusiness;

  FutureEither<String?> getAccessToken() async {
    final memory = _memoryAccessToken;
    if (memory != null && memory.isNotEmpty) {
      return right(memory);
    }
    return _storage.read(_accessTokenKey);
  }

  FutureEither<void> saveSession({
    required String accessToken,
    required Map<String, dynamic> business,
    bool persist = true,
  }) async {
    _memoryAccessToken = accessToken;
    _memoryBusiness = business;

    if (!persist) return right(null);

    final tokenResult = await _storage.write(_accessTokenKey, accessToken);
    return await tokenResult.fold(
      (failure) async => left(failure),
      (_) async => _storage.write(
        _businessProfileKey,
        jsonEncode(business),
      ),
    );
  }

  FutureEither<Map<String, dynamic>?> getCachedBusiness() async {
    if (_memoryBusiness != null) {
      return right(_memoryBusiness);
    }

    final result = await _storage.read(_businessProfileKey);
    return result.map((raw) {
      if (raw == null || raw.isEmpty) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    });
  }

  FutureEither<void> clearSession() async {
    _memoryAccessToken = null;
    _memoryBusiness = null;
    await _storage.delete(_accessTokenKey);
    await _storage.delete(_businessProfileKey);
    return right(null);
  }
}
