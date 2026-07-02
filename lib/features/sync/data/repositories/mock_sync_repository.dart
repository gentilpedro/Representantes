import '../../domain/entities/sync_summary.dart';
import '../../domain/repositories/sync_repository.dart';

/// Dados fixos espelhando a tela "Sincronização" do protótipo — cadastros e
/// check-ins pendentes (itens que não são pedidos, então não vêm do
/// `OrdersRepository`). `syncNow()` simula o envio da fila: zera os itens
/// pendentes e soma ao contador de sucesso, mantendo o conflito (que exige
/// resolução manual). Pedidos pendentes de verdade são compostos por cima
/// disto em `SyncController`, que também é quem decide quando chamar
/// `syncNow()` automaticamente.
class MockSyncRepository implements SyncRepository {
  SyncSummary _current = const SyncSummary(
    isConnected: true,
    lastUpdateLabel: 'Hoje às 08:45',
    pendingCount: 2,
    successCount: 128,
    conflict: SyncConflict(
      orderCode: '#9842',
      clientName: 'Supermercado Silva',
      reason: 'Limite de crédito excedido no ERP Josapar.',
    ),
    queue: [
      SyncQueueItem(
        id: 'q2',
        title: 'Cadastro Novo Cliente',
        subtitle: 'Padaria do Sr. Joaquim',
        tag: 'CPF/CNPJ',
        status: QueueItemStatus.offline,
        timeLabel: '09:15',
      ),
      SyncQueueItem(
        id: 'q3',
        title: 'Check-out de Visita',
        subtitle: 'Mercado da Vila',
        tag: 'Geo: -23.55, -46.63',
        status: QueueItemStatus.queued,
        timeLabel: '08:50',
      ),
    ],
    history: [
      SyncHistoryEntry(
        dateLabel: 'Hoje, 14 de Maio',
        summary: '12 processos finalizados',
      ),
      SyncHistoryEntry(
        dateLabel: 'Ontem, 13 de Maio',
        summary: 'Sincronização completa',
      ),
    ],
  );

  @override
  Future<SyncSummary> fetchSummary() async {
    await Future.delayed(const Duration(milliseconds: 450));
    return _current;
  }

  @override
  Future<SyncSummary> syncNow() async {
    await Future.delayed(const Duration(seconds: 1));
    _current = SyncSummary(
      isConnected: true,
      lastUpdateLabel: 'Agora mesmo',
      pendingCount: 0,
      successCount: _current.successCount + _current.queue.length,
      conflict: _current.conflict,
      queue: const [],
      history: _current.history,
    );
    return _current;
  }
}
