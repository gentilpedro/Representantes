/// Cliente em potencial (ainda não cadastrado como cliente de verdade).
/// Por enquanto só existe como estrutura de dados/cache local — a única
/// integração visível no app é aparecer como parada na Agenda de Visitas
/// (ver `ScheduledVisit.isProspect`); não há tela de gestão de leads ainda.
class Lead {
  const Lead({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.phone,
    this.notes = '',
  });

  final String id;
  final String name;
  final String address;
  final String city;
  final String state;
  final String phone;
  final String notes;
}
