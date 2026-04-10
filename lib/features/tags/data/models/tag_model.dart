import 'package:spendwise/features/tags/domain/entities/tag_entity.dart';

class TagModel extends TagEntity {
  TagModel({super.id, required super.userId, required super.name});

  factory TagModel.froJson(Map<String, dynamic> map) {
    return TagModel(id: map['TagID'], userId: map['userId'], name: map['name']);
  }

  Map<String, dynamic> toJson() => {"id": id, "userId": userId, "name": name};
}
