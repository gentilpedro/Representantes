import '../entities/sync_summary.dart';

/// Contrato de sincronização. A implementação real deve consumir a Web API
/// .NET 10 para enviar a fila local (pedidos, cadastros, check-ins pendentes)
/// e resolver conflitos contra o ERP.
abstract class SyncRepository {
  Future<SyncSummary> fetchSummary();

  /// Simula o envio da fila pendente e devolve o estado atualizado.
  Future<SyncSummary> syncNow();
}
