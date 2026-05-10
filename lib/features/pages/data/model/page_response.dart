// // تعليق: كائن لاستقبال الرد المجدول من السيرفر، حيث يحتوي على البيانات الوصفية للصفحات والبيانات الفعلية
class PagedResponse<T> {
  final List<T> data;
  final int pageNumber;
  final int pageSize;
  final int totalRecords;
  final int totalPages;

  PagedResponse({
    required this.data,
    required this.pageNumber,
    required this.pageSize,
    required this.totalRecords,
    required this.totalPages,
  });

  // // تعليق: دالة مصنع لتحويل الـ JSON القادم من السيرفر إلى كائن PagedResponse مع معالجة البيانات الداخلية
  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PagedResponse<T>(
      data: (json['data'] as List).map((item) => fromJsonT(item)).toList(),
      pageNumber: json['pageNumber'] ?? 1, // تغيير من PageNumber إلى pageNumber
      pageSize: json['pageSize'] ?? 10, // تغيير من PageSize إلى pageSize
      totalRecords:
          json['totalRecords'] ?? 0, // تغيير من TotalRecords إلى totalRecords
      totalPages: json['totalPages'] ?? 0, // تغيير من TotalPages إلى totalPages
    );
  }

  PagedResponse<T> copyWith({
    List<T>? data,
    int? pageNumber,
    int? pageSize,
    int? totalRecords,
    int? totalPages,
  }) {
    return PagedResponse<T>(
      data: data ?? this.data,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      totalRecords: totalRecords ?? this.totalRecords,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}
