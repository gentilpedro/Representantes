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
  });

  final String id;
  final String clientName;
  final String scheduledTimeLabel;
  final String address;
  final VisitStatus status;
  final String notes;
  final bool isGeoValidated;

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
    );
  }
}
