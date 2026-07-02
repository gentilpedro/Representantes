import 'product.dart';

enum StockLevel { high, medium, critical }

class WarehouseStock {
  const WarehouseStock({
    required this.warehouseName,
    required this.state,
    required this.bundlesAvailable,
    required this.level,
  });

  final String warehouseName;
  final String state;
  final int bundlesAvailable;
  final StockLevel level;
}

class ProductDetail {
  const ProductDetail({
    required this.product,
    required this.categoryLabel,
    required this.images,
    required this.appliedPromotions,
    required this.stockByWarehouse,
    required this.commercialDescription,
    required this.technicalSpecs,
  });

  final Product product;
  final String categoryLabel;
  final List<String> images;
  final List<String> appliedPromotions;
  final List<WarehouseStock> stockByWarehouse;
  final String commercialDescription;
  final Map<String, String> technicalSpecs;
}
