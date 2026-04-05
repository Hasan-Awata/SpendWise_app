class TagEntity {
  final int? id;
  final int categoryId;
  final int ownerId;
  final String label;

  TagEntity({
    this.id,
    required this.ownerId,
    required this.label,
    required this.categoryId,
  });
}
