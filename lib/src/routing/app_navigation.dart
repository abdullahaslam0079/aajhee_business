import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:goluto_business/src/routing/app_routes.dart';

void navigateAfterAuthentication(BuildContext context) {
  context.go(AppRoutes.dashboard);
}
