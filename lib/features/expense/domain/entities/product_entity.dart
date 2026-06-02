class ProductEntity {
  final String name;
  final int quantity;
  final double price;

  const ProductEntity({
    required this.name,
    required this.quantity,
    required this.price,
  });

  // =====================================================
  // COPY WITH (اختياري لكنه مفيد جداً)
  // =====================================================
  ProductEntity copyWith({String? name, int? quantity, double? price}) {
    return ProductEntity(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  // =====================================================
  // TOTAL PRICE (اختياري مفيد للحسابات)
  // =====================================================
  double get total => quantity * price;
}
