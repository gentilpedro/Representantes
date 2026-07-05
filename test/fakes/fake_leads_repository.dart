import 'package:josapar_representantes/features/leads/domain/entities/lead.dart';
import 'package:josapar_representantes/features/leads/domain/leads_exception.dart';
import 'package:josapar_representantes/features/leads/domain/repositories/leads_repository.dart';

class FakeLeadsRepository implements LeadsRepository {
  FakeLeadsRepository() : _leads = List.of(_seed);

  static final _seed = <Lead>[
    Lead(
      id: 'l1',
      contactName: 'Joana Martins',
      companyName: 'Mercearia do Bairro',
      phone: '(51) 98888-1111',
      email: 'joana@merceariadobairro.example.com',
      status: LeadStatus.new_,
      source: 'Indicação',
      createdAtUtc: DateTime.utc(2026, 6, 20),
    ),
    Lead(
      id: 'l2',
      contactName: 'Carlos Souza',
      companyName: 'Empório Boa Sorte',
      phone: '(51) 98888-2222',
      status: LeadStatus.contacted,
      createdAtUtc: DateTime.utc(2026, 6, 15),
      lastContactAtUtc: DateTime.utc(2026, 6, 25),
    ),
  ];

  final List<Lead> _leads;
  int _sequence = 100;

  @override
  Future<List<Lead>> fetchLeads() async => List.of(_leads);

  @override
  Future<Lead> fetchLead(String id) async {
    final matches = _leads.where((l) => l.id == id);
    if (matches.isEmpty) throw LeadsException('Lead não encontrado.');
    return matches.first;
  }

  @override
  Future<Lead> createLead({
    required String contactName,
    required String companyName,
    String? cnpj,
    required String phone,
    String? email,
    String? source,
    String? notes,
  }) async {
    _sequence++;
    final lead = Lead(
      id: 'l$_sequence',
      contactName: contactName,
      companyName: companyName,
      cnpj: cnpj,
      phone: phone,
      email: email,
      status: LeadStatus.new_,
      source: source,
      notes: notes,
      createdAtUtc: DateTime.now().toUtc(),
    );
    _leads.insert(0, lead);
    return lead;
  }

  @override
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
  }) async {
    final index = _leads.indexWhere((l) => l.id == id);
    if (index == -1) throw LeadsException('Lead não encontrado.');
    final updated = Lead(
      id: id,
      contactName: contactName,
      companyName: companyName,
      cnpj: cnpj,
      phone: phone,
      email: email,
      status: status,
      source: source,
      notes: notes,
      createdAtUtc: _leads[index].createdAtUtc,
      lastContactAtUtc: lastContactAtUtc,
    );
    _leads[index] = updated;
    return updated;
  }
}
