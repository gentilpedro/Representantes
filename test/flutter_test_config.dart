import 'dart:async';

import 'package:package_info_plus/package_info_plus.dart';

/// `PackageInfo.fromPlatform()` bate num canal de plataforma sem mock no
/// `flutter_test` (mesma classe de problema do `path_provider`/Drift) — sem
/// isso, qualquer tela que leia `packageInfoProvider` (Boas-vindas, Perfil)
/// trava o teste. Roda antes de toda a suíte automaticamente.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  PackageInfo.setMockInitialValues(
    appName: 'Josapar Representantes',
    packageName: 'com.josapar.representantes',
    version: '1.0.0',
    buildNumber: '1',
    buildSignature: '',
  );
  await testMain();
}
