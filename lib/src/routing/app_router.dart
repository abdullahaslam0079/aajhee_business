import 'package:go_router/go_router.dart';
import 'package:goluto_business/src/features/auth/presentation/screens/business_login_screen.dart';
import 'package:goluto_business/src/features/auth/presentation/screens/business_register_screen.dart';
import 'package:goluto_business/src/features/branches/presentation/screens/branch_form_screen.dart';
import 'package:goluto_business/src/features/branches/presentation/screens/branches_screen.dart';
import 'package:goluto_business/src/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:goluto_business/src/features/items/presentation/screens/item_form_screen.dart';
import 'package:goluto_business/src/features/items/presentation/screens/items_screen.dart';
import 'package:goluto_business/src/features/offers/presentation/screens/offer_detail_screen.dart';
import 'package:goluto_business/src/features/offers/presentation/screens/offer_form_screen.dart';
import 'package:goluto_business/src/features/offers/presentation/screens/offers_screen.dart';
import 'package:goluto_business/src/routing/app_routes.dart';
import 'package:goluto_business/src/routing/global_navigator.dart';

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.login,
  redirect: (context, state) {
    return null;
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
    GoRoute(
      path: AppRoutes.items,
      name: 'items',
      builder: (context, state) => const ItemsScreen(),
      routes: [
        GoRoute(
          path: 'create',
          name: 'itemCreate',
          builder: (context, state) => const ItemFormScreen(),
        ),
        GoRoute(
          path: ':id/edit',
          name: 'itemEdit',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ItemFormScreen(itemId: id);
          },
        ),
      ],
    ),
  ],
);
