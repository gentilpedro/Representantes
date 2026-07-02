/// Configuração de acesso à Web API (.NET 10).
///
/// A URL real deve ser definida via `--dart-define=API_BASE_URL=https://...`
/// no momento do build/run. Enquanto a API não está disponível, os
/// repositórios das features usam implementações mock (veja `data/repositories`
/// de cada feature) e este cliente fica pronto para ser plugado assim que o
/// endpoint existir.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.josapar.example.com',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
