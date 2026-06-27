import 'package:dio/dio.dart';
import 'package:goluto_business/src/services/auth_token_service.dart';

/// Attaches the stored JWT to outgoing API requests.
class AuthInterceptor extends QueuedInterceptorsWrapper {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final tokenResult = await AuthTokenService.instance.getAccessToken();
    tokenResult.fold(
      (_) {},
      (token) {
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      },
    );
    handler.next(options);
  }
}
