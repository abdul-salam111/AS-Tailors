class RoutePaths {
  static const String signin = '/signin';
  static const String splash = '/splash';
  static const String profile = '/profile';
  static const String home = '/home';
  static const String orders = '/orders';
  static const String customers = '/customers';
  static const String addCustomer = '/customers/add';
  static const String customerDetail = '/customers/:id';
  static const String editCustomer = '/customers/:id/edit';
  static const String addMeasurement = '/customers/:id/measurements/add';

  // Concrete-path builders for the parameterized routes above — use these
  // at navigation call sites instead of hand-interpolating ':id'.
  static String customerDetailPath(String id) => '/customers/$id';
  static String editCustomerPath(String id) => '/customers/$id/edit';
  static String addMeasurementPath(String customerId) => '/customers/$customerId/measurements/add';
}
