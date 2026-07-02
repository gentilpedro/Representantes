import 'package:hive/hive.dart';

/// Registro gravado no Hive (box `pending_orders`) enquanto um pedido feito
/// offline aguarda sincronização. Existe *só* enquanto o pedido está
/// pendente — assim que `SyncController` sincroniza com sucesso, o registro
/// é apagado da box (ver `MockOrdersRepository.syncPendingOrders`).
class OfflineOrderRecord {
  OfflineOrderRecord({
    required this.id,
    required this.code,
    required this.clientName,
    required this.itemsCount,
    required this.total,
    required this.dateLabel,
  });

  final String id;
  final String code;
  final String clientName;
  final int itemsCount;
  final double total;
  final String dateLabel;
}

class OfflineOrderRecordAdapter extends TypeAdapter<OfflineOrderRecord> {
  @override
  final int typeId = 0;

  @override
  OfflineOrderRecord read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineOrderRecord(
      id: fields[0] as String,
      code: fields[1] as String,
      clientName: fields[2] as String,
      itemsCount: fields[3] as int,
      total: fields[4] as double,
      dateLabel: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineOrderRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.code)
      ..writeByte(2)
      ..write(obj.clientName)
      ..writeByte(3)
      ..write(obj.itemsCount)
      ..writeByte(4)
      ..write(obj.total)
      ..writeByte(5)
      ..write(obj.dateLabel);
  }
}
