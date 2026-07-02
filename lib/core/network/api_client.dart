import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../storage/session_storage.dart';
import 'api_config.dart';

/// Wrapper único do [Dio] usado por todos os repositórios "reais" (não-mock)
/// assim que a Web API .NET 10 estiver disponível. Injeta o token JWT salvo
/// em [SessionStorage] em toda requisição autenticada.
class ApiClient {
  ApiClient(this._sessionStorage)
    : dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: ApiConfig.connectTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _sessionStorage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
    dio.interceptors.add(
      PrettyDioLogger(requestBody: true, responseBody: true, error: true),
    );
  }

  final Dio dio;
  final SessionStorage _sessionStorage;
}
