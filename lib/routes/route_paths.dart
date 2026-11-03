class RoutePaths {
  static const String signin = '/signin';
  static const String signup = '/signup';
  static const String splash = '/splash';
  static const String profile = '/profile';
  static const String createShop = '/create-shop';
  static const String home = '/home';
  static const String customers = '/customers';
  static const String addCustomer = '/customers/add';
  static const String customerDetail = '/customers/:id';
  static const String editCustomer = '/customers/:id/edit';

  // Concrete-path builders for the two parameterized routes above — use
  // these at navigation call sites instead of hand-interpolating ':id'.
  static String customerDetailPath(String id) => '/customers/$id';
  static String editCustomerPath(String id) => '/customers/$id/edit';
}
