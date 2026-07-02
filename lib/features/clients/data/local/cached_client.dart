import 'package:hive/hive.dart';

import '../../domain/entities/client_list_item.dart';

/// Espelho de [ClientListItem] gravável no Hive (box `clients_cache`).
/// Mesma ideia de `CachedProduct`: última carteira de clientes baixada do
/// servidor, disponível offline entre atualizações.
///
/// [sortOrder] existe porque `Box.values` do Hive itera em ordem de hash
/// interna, não de inserção — sem isso a ordem da lista fica embaralhada a
/// cada leitura.
class CachedClient {
  CachedClient({
    required this.id,
    required this.code,
    required this.name,
    required this.cnpj,
    required this.city,
    required this.state,
    required this.tierIndex,
    required this.lastOrderDateLabel,
    required this.creditLimit,
    required this.sortOrder,
    this.isFavorite = false,
    this.isOffline = false,
  });

  factory CachedClient.fromClient(
    ClientListItem client, {
    required int sortOrder,
  }) {
    return CachedClient(
      id: client.id,
      code: client.code,
      name: client.name,
      cnpj: client.cnpj,
      city: client.city,
      state: client.state,
      tierIndex: client.tier.index,
      lastOrderDateLabel: client.lastOrderDateLabel,
      creditLimit: client.creditLimit,
      sortOrder: sortOrder,
      isFavorite: client.isFavorite,
      isOffline: client.isOffline,
    );
  }

  final String id;
  final String code;
  final String name;
  final String cnpj;
  final String city;
  final String state;
  final int tierIndex;
  final String lastOrderDateLabel;
  final double creditLimit;
  final int sortOrder;
  final bool isFavorite;
  final bool isOffline;

  ClientListItem toClient() {
    return ClientListItem(
      id: id,
      code: code,
      name: name,
      cnpj: cnpj,
      city: city,
      state: state,
      tier: ClientTier.values[tierIndex],
      lastOrderDateLabel: lastOrderDateLabel,
      creditLimit: creditLimit,
      isFavorite: isFavorite,
      isOffline: isOffline,
    );
  }
}

class CachedClientAdapter extends TypeAdapter<CachedClient> {
  @override
  final int typeId = 2;

  @override
  CachedClient read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    return CachedClient(
      id: fields[0] as String,
      code: fields[1] as String,
      name: fields[2] as String,
      cnpj: fields[3] as String,
      city: fields[4] as String,
      state: fields[5] as String,
      tierIndex: fields[6] as int,
      lastOrderDateLabel: fields[7] as String,
      creditLimit: fields[8] as double,
      isFavorite: fields[9] as bool,
      isOffline: fields[10] as bool,
      sortOrder: fields[11] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CachedClient obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.code)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.cnpj)
      ..writeByte(4)
      ..write(obj.city)
      ..writeByte(5)
      ..write(obj.state)
      ..writeByte(6)
      ..write(obj.tierIndex)
      ..writeByte(7)
      ..write(obj.lastOrderDateLabel)
      ..writeByte(8)
      ..write(obj.creditLimit)
      ..writeByte(9)
      ..write(obj.isFavorite)
      ..writeByte(10)
      ..write(obj.isOffline)
      ..writeByte(11)
      ..write(obj.sortOrder);
  }
}
