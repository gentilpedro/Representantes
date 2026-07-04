import '../entities/lead.dart';

/// Contrato de Leads (futuros clientes), contra `GET/POST /api/leads` e
/// `GET/PATCH /api/leads/{id}` da Web API .NET 10.
abstract class LeadsRepository {
  Future<List<Lead>> fetchLeads();

  Future<Lead> fetchLead(String id);

  /// Sempre cria com `status: new` — a API não aceita status na criação.
  Future<Lead> createLead({
    required String contactName,
    required String companyName,
    String? cnpj,
    required String phone,
    String? email,
    String? source,
    String? notes,
  });

  Future<Lead> updateLead({
    required String id,
    required String contactName,
    required String companyName,
    String? cnpj,
    required String phone,
    String? email,
    required LeadStatus status,
    String? source,
    String? notes,
    DateTime? lastContactAtUtc,
  });
}
