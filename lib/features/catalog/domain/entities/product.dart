enum ProductBadge { none, offer, outOfStock }

class Product {
  const Product({
    required this.id,
    required this.sku,
    required this.brand,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.price,
    required this.availableUnits,
    this.originalPrice,
    this.badge = ProductBadge.none,
    this.isFavorite = false,
  });

  final String id;
  final String sku;
  final String brand;
  final String name;
  final String category;
  final String imageUrl;
  final double price;
  final int availableUnits;
  final double? originalPrice;
  final ProductBadge badge;
  final bool isFavorite;

  bool get isOutOfStock => badge == ProductBadge.outOfStock;

  int? get discountPercent {
    if (originalPrice == null || originalPrice == 0) return null;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }
}
