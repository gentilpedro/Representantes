import 'package:hive/hive.dart';

import '../../domain/entities/product.dart';

/// Espelho de [Product] gravável no Hive (box `products_cache`). Guarda o
/// catálogo baixado do servidor na última atualização (hoje simulada,
/// semanal quando existir a Web API), para o app funcionar 100% offline
/// entre atualizações.
///
/// [sortOrder] existe porque `Box.values` do Hive itera em ordem de hash
/// interna, não de inserção — sem isso a ordem do catálogo fica embaralhada
/// a cada leitura.
class CachedProduct {
  CachedProduct({
    required this.id,
    required this.sku,
    required this.brand,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.price,
    required this.availableUnits,
    required this.sortOrder,
    this.originalPrice,
    this.badgeIndex = 0,
    this.isFavorite = false,
  });

  factory CachedProduct.fromProduct(Product product, {required int sortOrder}) {
    return CachedProduct(
      id: product.id,
      sku: product.sku,
      brand: product.brand,
      name: product.name,
      category: product.category,
      imageUrl: product.imageUrl,
      price: product.price,
      availableUnits: product.availableUnits,
      sortOrder: sortOrder,
      originalPrice: product.originalPrice,
      badgeIndex: product.badge.index,
      isFavorite: product.isFavorite,
    );
  }

  final String id;
  final String sku;
  final String brand;
  final String name;
  final String category;
  final String imageUrl;
  final double price;
  final int availableUnits;
  final int sortOrder;
  final double? originalPrice;
  final int badgeIndex;
  final bool isFavorite;

  Product toProduct() {
    return Product(
      id: id,
      sku: sku,
      brand: brand,
      name: name,
      category: category,
      imageUrl: imageUrl,
      price: price,
      availableUnits: availableUnits,
      originalPrice: originalPrice,
      badge: ProductBadge.values[badgeIndex],
      isFavorite: isFavorite,
    );
  }
}

class CachedProductAdapter extends TypeAdapter<CachedProduct> {
  @override
  final int typeId = 1;

  @override
  CachedProduct read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    return CachedProduct(
      id: fields[0] as String,
      sku: fields[1] as String,
      brand: fields[2] as String,
      name: fields[3] as String,
      category: fields[4] as String,
      imageUrl: fields[5] as String,
      price: fields[6] as double,
      availableUnits: fields[7] as int,
      originalPrice: fields[8] as double?,
      badgeIndex: fields[9] as int,
      isFavorite: fields[10] as bool,
      sortOrder: fields[11] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CachedProduct obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sku)
      ..writeByte(2)
      ..write(obj.brand)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(6)
      ..write(obj.price)
      ..writeByte(7)
      ..write(obj.availableUnits)
      ..writeByte(8)
      ..write(obj.originalPrice)
      ..writeByte(9)
      ..write(obj.badgeIndex)
      ..writeByte(10)
      ..write(obj.isFavorite)
      ..writeByte(11)
      ..write(obj.sortOrder);
  }
}
