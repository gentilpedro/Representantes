enum LeadStatus { new_, contacted, qualified, converted, lost }

class Lead {
  const Lead({
    required this.id,
    required this.contactName,
    required this.companyName,
    this.cnpj,
    required this.phone,
    this.email,
    required this.status,
    this.source,
    this.notes,
    required this.createdAtUtc,
    this.lastContactAtUtc,
  });

  final String id;
  final String contactName;
  final String companyName;
  final String? cnpj;
  final String phone;
  final String? email;
  final LeadStatus status;
  final String? source;
  final String? notes;
  final DateTime createdAtUtc;
  final DateTime? lastContactAtUtc;
}
