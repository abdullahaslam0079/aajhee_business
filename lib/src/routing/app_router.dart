import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:goluto_business/src/features/auth/presentation/providers/session_provider.dart';
import 'package:goluto_business/src/features/auth/presentation/screens/business_login_screen.dart';
import 'package:goluto_business/src/features/auth/presentation/screens/business_register_screen.dart';
import 'package:goluto_business/src/features/branches/presentation/screens/branch_form_screen.dart';
import 'package:goluto_business/src/features/branches/presentation/screens/branches_screen.dart';
import 'package:goluto_business/src/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:goluto_business/src/features/offers/presentation/screens/offer_detail_screen.dart';
import 'package:goluto_business/src/features/offers/presentation/screens/offer_form_screen.dart';
import 'package:goluto_business/src/features/offers/presentation/screens/offers_screen.dart';
import 'package:goluto_business/src/imports/packages_imports.dart';
import 'package:goluto_business/src/routing/app_routes.dart';
import 'package:goluto_business/src/routing/global_navigator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    ref.listen<SessionState>(sessionProvider, (_, __) => notifyListeners());
  }
}

bool _isAuthRoute(String location) {
  return location == AppRoutes.login || location == AppRoutes.register;
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refresh = _RouterRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.login,
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final location = state.matchedLocation;

      if (session.status == SessionStatus.unknown) {
        return null;
      }

      if (session.status == SessionStatus.authenticated) {
        return _isAuthRoute(location) ? AppRoutes.dashboard : null;
      }

      return _isAuthRoute(location) ? null : AppRoutes.login;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const BusinessLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const BusinessRegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.branches,
        name: 'branches',
        builder: (context, state) => const BranchesScreen(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'branchCreate',
            builder: (context, state) => const BranchFormScreen(),
          ),
          GoRoute(
            path: ':id/edit',
            name: 'branchEdit',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return BranchFormScreen(branchId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.offers,
        name: 'offers',
        builder: (context, state) => const OffersScreen(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'offerCreate',
            builder: (context, state) => const OfferFormScreen(),
          ),
          GoRoute(
            path: ':id',
            name: 'offerDetail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return OfferDetailScreen(offerId: id);
            },
            routes: [
              GoRoute(
                path: 'edit',
                name: 'offerEdit',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return OfferFormScreen(offerId: id);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
