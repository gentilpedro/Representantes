import 'dart:async';

import 'package:josapar_representantes/core/services/connectivity_service.dart';

/// `AppShell` mantém o `SyncController` sempre ativo, que checa
/// conectividade real via `connectivity_plus` — sem handler mockado isso
/// trava o teste, então sempre sobrescrevemos por uma versão controlável.
class FakeConnectivityService implements ConnectivityService {
  // ignore: prefer_initializing_formals
  FakeConnectivityService({bool isOnline = true}) : _isOnline = isOnline;

  bool _isOnline;
  final _controller = StreamController<bool>.broadcast();

  @override
  Future<bool> isOnline() async => _isOnline;

  @override
  Stream<bool> get onStatusChange => _controller.stream;

  void goOnline() {
    _isOnline = true;
    _controller.add(true);
  }

  void goOffline() {
    _isOnline = false;
    _controller.add(false);
  }

  void dispose() => _controller.close();
}
