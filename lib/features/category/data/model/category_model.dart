import 'package:uuid/uuid.dart';

class CategoryModel {
  final String localId; // المعرف المحلي الفريد لضمان العمل Offline
  int? categoryId; // المعرف القادم من الباك إند (CategoryId)
  String name; // اسم التصنيف (Name)
  final int priority; // الأولوية (Priority من 1 إلى 4)

  CategoryModel({
    String? localId,
    this.categoryId = 1, // القيمة الافتراضية كما ذكرت في الباك إند
    required this.name,
    required this.priority,
  }) : localId = localId ?? const Uuid().v4();

  // // Logic: دالة copyWith للحفاظ على الـ Immutability وتعديل البيانات
  CategoryModel copyWith({String? name, int? priority, int? categoryId}) {
    return CategoryModel(
      localId: this.localId,
      name: name ?? this.name,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  // // Logic: التحويل من JSON (عند استلام البيانات من API الباك إند)
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      // نتحقق من وجود المعرف المحلي، إذا لم يوجد نولد واحد جديد
      localId: json['localId'],
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
