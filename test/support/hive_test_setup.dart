import 'dart:io';

import 'package:hive/hive.dart';
import 'package:josapar_representantes/core/storage/hive_init.dart';

/// Inicializa uma instância Hive real, porém efêmera (pasta temporária),
/// para os testes de widget que tocam pedidos/catálogo/clientes/leads. Hive
/// não usa platform channels, então funciona de verdade em `flutter_test`
/// sem precisar de fakes — chame isto num `setUpAll`.
Future<void> setUpHiveForTest() async {
  final tempDir = Directory.systemTemp.createTempSync('josapar_hive_test_');
  Hive.init(tempDir.path);
  await initHive();
}
