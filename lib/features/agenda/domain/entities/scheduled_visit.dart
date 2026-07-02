enum VisitStatus { pending, inProgress, completed }

class ScheduledVisit {
  const ScheduledVisit({
    required this.id,
    required this.clientName,
    required this.scheduledTimeLabel,
    required this.address,
    required this.status,
    this.notes = '',
    this.isGeoValidated = false,
    this.isProspect = false,
  });

  final String id;
  final String clientName;
  final String scheduledTimeLabel;
  final String address;
  final VisitStatus status;
  final String notes;
  final bool isGeoValidated;

  /// `true` quando a parada é um cliente em potencial (lead), não um
  /// cliente já cadastrado — ver `LeadsRepository`.
  final bool isProspect;

  ScheduledVisit copyWith({
    VisitStatus? status,
    String? notes,
    bool? isGeoValidated,
  }) {
    return ScheduledVisit(
      id: id,
      clientName: clientName,
      scheduledTimeLabel: scheduledTimeLabel,
      address: address,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      isGeoValidated: isGeoValidated ?? this.isGeoValidated,
      isProspect: isProspect,
    );
  }
}
