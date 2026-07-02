import 'dart:async';

import 'package:hive/hive.dart';

import '../../domain/entities/lead.dart';
import '../../domain/repositories/leads_repository.dart';
import '../local/cached_lead.dart';

/// Carteira de leads cacheada localmente (box `leads_cache`). Na primeira
/// execução semeia com dados de exemplo, simulando "o último download do
/// servidor" — quando a Web API existir, [refreshCache] passa a baixar de
/// verdade em vez de re-semear os mesmos exemplos.
class MockLeadsRepository implements LeadsRepository {
  MockLeadsRepository(this._box) {
    if (_box.isEmpty) {
      for (var i = 0; i < _seedLeads.length; i++) {
        final lead = _seedLeads[i];
        _box.put(lead.id, CachedLead.fromLead(lead, sortOrder: i));
      }
    }
  }

  final Box<CachedLead> _box;

  static const _seedLeads = [
    Lead(
      id: 'lead-mercadinho-vila',
      name: 'Mercadinho Vila Nova (potencial)',
      address: 'Rua Marechal Deodoro, 780 - Vila Nova, Pelotas - RS',
      city: 'Pelotas',
      state: 'RS',
      phone: '(53) 99888-4455',
      notes: 'Indicação de cliente atual. Ainda não fez pedido.',
    ),
    Lead(
      id: 'lead-empório-sul',
      name: 'Empório Sul Distribuidora (potencial)',
      address: 'Av. Duque de Caxias, 2100 - Fragata, Pelotas - RS',
      city: 'Pelotas',
      state: 'RS',
      phone: '(53) 99777-3322',
      notes: 'Contato feito via feira do setor em outubro.',
    ),
  ];

  @override
  Future<List<Lead>> fetchLeads() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final cached = _box.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return cached.map((c) => c.toLead()).toList();
  }

  /// Reaponta o cache para os dados mais recentes do servidor. Sem uma Web
  /// API real ainda, só re-semeia os mesmos exemplos — a peça (box +
  /// método) já fica pronta para virar um download de verdade depois.
  Future<void> refreshCache() async {
    // Não aguarda o flush em disco (mesmo motivo de `MockOrdersRepository`):
    // `Box.clear`/`Box.put` já atualizam o estado em memória na hora.
    unawaited(_box.clear());
    for (var i = 0; i < _seedLeads.length; i++) {
      final lead = _seedLeads[i];
      unawaited(_box.put(lead.id, CachedLead.fromLead(lead, sortOrder: i)));
    }
  }
}
