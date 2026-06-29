import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:goluto_business/src/features/auth/presentation/providers/session_provider.dart';
import 'package:goluto_business/src/routing/app_routes.dart';

void navigateAfterAuthentication(BuildContext context) {
  context.go(AppRoutes.dashboard);
}

Future<void> navigateFromSplash(BuildContext context, WidgetRef ref) async {
  if (!context.mounted) return;

  FlutterNativeSplash.remove();

  final session = ref.read(sessionProvider);
  if (session.status == SessionStatus.authenticated) {
    context.go(AppRoutes.dashboard);
    return;
  }

  context.go(AppRoutes.login);
}
