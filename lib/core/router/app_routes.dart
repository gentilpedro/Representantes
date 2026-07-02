class AppRoutes {
  AppRoutes._();

  static const splash = '/splash';
  static const welcome = '/welcome';
  static const login = '/login';
  static const firstAccess = '/first-access';
  static const createPassword = '/first-access/create-password';

  static const dashboard = '/dashboard';
  static const clients = '/clients';
  static String clientDetail(String clientId) => '/clients/$clientId';
  static const orders = '/orders';
  static const agenda = '/agenda';
  static const more = '/more';

  static const newOrder = '/orders/new';
  static const selectClient = '/orders/new/select-client';
  static const catalog = '/catalog';
  static String productDetail(String productId) => '/catalog/$productId';
  static const notifications = '/notifications';
  static const profile = '/more/profile';
  static const sync = '/more/sync';
  static const reports = '/more/reports';
}
