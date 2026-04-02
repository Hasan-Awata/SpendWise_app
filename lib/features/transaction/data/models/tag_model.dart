import 'package:spendwise/features/transaction/domain/entities/tag_entity.dart';

class TagModel extends TagEntity {
  TagModel({
    super.id,
    required super.ownerId,
    required super.label,
    required super.categoryId,
  });

  factory TagModel.fromMap(Map<String, dynamic> map) {
    return TagModel(
      id: map['TagID'],
      ownerId: map['ownerID'],
      label: map['label'],
      categoryId: map['categoryId'],
    );
  }

  Map<String, dynamic> toMap() => {
    "id": id,
    "ownerId": ownerId,
    "categoryId": categoryId,
    "label": label,
  };
}
