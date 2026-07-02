import '../entities/lead.dart';

/// Contrato para a carteira de leads (clientes em potencial). A
/// implementação real baixaria isso da Web API .NET 10 periodicamente
/// (mesma cadência semanal do cache de produtos/clientes).
abstract class LeadsRepository {
  Future<List<Lead>> fetchLeads();
}
