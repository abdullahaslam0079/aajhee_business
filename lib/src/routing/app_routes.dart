/// Centralized route path constants for GoRouter.
abstract final class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';

  static const String branches = '/branches';
  static const String branchCreate = '/branches/create';
  static String branchEdit(String id) => '/branches/$id/edit';
  static String branchFulfillment(String id) => '/branches/$id/fulfillment';

  static const String offers = '/offers';
  static const String offerCreate = '/offers/create';
  static String offerEdit(String id) => '/offers/$id/edit';
  static String offerDetail(String id) => '/offers/$id';

  static const String products = '/products';
  static const String productCreate = '/products/create';
  static String productEdit(String id) => '/products/$id/edit';

  static const String orders = '/orders';
  static String orderDetail(String publicId) => '/orders/$publicId';
}
