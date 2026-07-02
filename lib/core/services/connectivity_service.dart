import 'package:connectivity_plus/connectivity_plus.dart';

/// Fino wrapper sobre `connectivity_plus`, expondo apenas um booleano
/// "está online?" — usado para disparar a sincronização automática assim
/// que a conexão volta (ver `SyncController`).
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  Stream<bool> get onStatusChange => _connectivity.onConnectivityChanged.map(
    (results) => !results.contains(ConnectivityResult.none),
  );
}
