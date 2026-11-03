import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityService {
  final InternetConnection _checker;

  ConnectivityService() : _checker = InternetConnection();

  Future<bool> get isConnected => _checker.hasInternetAccess;

  Stream<InternetStatus> get onStatusChange => _checker.onStatusChange;
}
