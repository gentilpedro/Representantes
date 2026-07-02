import 'package:hive/hive.dart';

import '../../domain/entities/lead.dart';

/// Espelho de [Lead] gravável no Hive (box `leads_cache`).
///
/// [sortOrder] existe porque `Box.values` do Hive itera em ordem de hash
/// interna, não de inserção — sem isso a ordem da lista fica embaralhada a
/// cada leitura.
class CachedLead {
  CachedLead({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.phone,
    required this.sortOrder,
    this.notes = '',
  });

  factory CachedLead.fromLead(Lead lead, {required int sortOrder}) {
    return CachedLead(
      id: lead.id,
      name: lead.name,
      address: lead.address,
      city: lead.city,
      state: lead.state,
      phone: lead.phone,
      sortOrder: sortOrder,
      notes: lead.notes,
    );
  }

  final String id;
  final String name;
  final String address;
  final String city;
  final String state;
  final String phone;
  final int sortOrder;
  final String notes;

  Lead toLead() {
    return Lead(
      id: id,
      name: name,
      address: address,
      city: city,
      state: state,
      phone: phone,
      notes: notes,
    );
  }
}

class CachedLeadAdapter extends TypeAdapter<CachedLead> {
  @override
  final int typeId = 3;

  @override
  CachedLead read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    return CachedLead(
      id: fields[0] as String,
      name: fields[1] as String,
      address: fields[2] as String,
      city: fields[3] as String,
      state: fields[4] as String,
      phone: fields[5] as String,
      notes: fields[6] as String,
      sortOrder: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CachedLead obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.city)
      ..writeByte(4)
      ..write(obj.state)
      ..writeByte(5)
      ..write(obj.phone)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.sortOrder);
  }
}
