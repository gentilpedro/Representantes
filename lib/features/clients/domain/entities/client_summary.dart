/// Versão enxuta do cliente, usada na lista de Clientes e como "cliente
/// selecionado" no fluxo de Novo Pedido. A tela de Detalhe do Cliente
/// (Etapa 3) usa uma entidade mais completa que reaproveita estes campos.
class ClientSummary {
  const ClientSummary({
    required this.id,
    required this.name,
    required this.cnpj,
    required this.code,
    required this.creditLimit,
  });

  final String id;
  final String name;
  final String cnpj;
  final String code;
  final double creditLimit;
}
