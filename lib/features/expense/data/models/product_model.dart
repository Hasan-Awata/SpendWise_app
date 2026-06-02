// product_model.dart

import 'package:isar/isar.dart';

part 'product_model.g.dart';

@embedded
class ProductModel {
  String name = '';
  int quantity = 0;
  double price = 0;

  ProductModel({this.name = '', this.quantity = 0, this.price = 0});

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'quantity': quantity, 'price': price};
  }

  @override
  String toString() {
    return '''
ProductModel(
  name: $name,
  quantity: $quantity,
  price: $price
)
''';
  }
}
