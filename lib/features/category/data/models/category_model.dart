import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'category_model.g.dart';

@collection
class CategoryModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  String localId; // المعرف المحلي الفريد لضمان العمل Offline
  @Index()
  int? categoryId; // المعرف القادم من الباك إند (CategoryId)
  String name; // اسم التصنيف (Name)
  final int priority; // الأولوية (Priority من 1 إلى 4)

  CategoryModel({
    String? localIdUid,
    this.categoryId = 1, // القيمة الافتراضية كما ذكرت في الباك إند
    required this.name,
    required this.priority,
  }) : localId = localIdUid ?? const Uuid().v4();

  // // Logic: دالة copyWith للحفاظ على الـ Immutability وتعديل البيانات
  CategoryModel copyWith({String? name, int? priority, int? categoryId}) {
    return CategoryModel(
      localIdUid: localId,
      name: name ?? this.name,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  // // Logic: التحويل من JSON (عند استلام البيانات من API الباك إند)
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      // نتحقق من وجود المعرف المحلي، إذا لم يوجد نولد واحد جديد
      localIdUid: json['localId'],
      categoryId: json['categoryId'] ?? -1,
      name: json['name'] ?? '',
      priority: json['priority'] ?? 1,
    );
  }

  // // Logic: التحويل إلى JSON (عند إرسال البيانات للباك إند)
  Map<String, dynamic> toJson() {
    return {
      'localId': localId,
      'categoryId': categoryId,
      'name': name,
      'priority': priority,
    };
  }
}
