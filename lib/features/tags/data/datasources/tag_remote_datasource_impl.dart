import 'package:dio/dio.dart';
import 'package:spendwise/core/network/api_endpoints.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/tags/data/datasources/tag_remote_datasource.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';

class TagRemoteDatasourceImpl implements TagRemoteDatasource {
  final Dio dio;
  TagRemoteDatasourceImpl({required this.dio});

  @override
  Future<TagModel> addTag(TagModel tag) async {
    try {
      final response = await dio.post(ApiEndpoints.tag, data: tag.toJson());

      // تصحيح: التأكد من الوصول للحقل الصحيح في الاستجابة (غالباً data أو الاستجابة مباشرة)
      if (response.data != null) {
        // إذا كان السيرفر يعيد الكائن داخل حقل 'data'
        if (response.data is Map && response.data.containsKey('data')) {
          return TagModel.fromJson(response.data['data']);
        }
        // إذا كان يعيد الكائن مباشرة
        return TagModel.fromJson(response.data);
      }
      throw Exception("استجابة فارغة من السيرفر");
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<void> deleteTag(TagModel tag) async {
    try {
      await dio.delete("${ApiEndpoints.tag}/${tag.id}");
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<void> updateTag(TagModel tag) async {
    try {
      // تصحيح: تمرير البيانات المراد تحديثها في الـ patch
      await dio.patch("${ApiEndpoints.tag}/${tag.id}", data: tag.toJson());
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<PagedResponse<TagModel>> getMyTags(PageRequest page) async {
    try {
      // تصحيح: تغيير wallet إلى tag
      final response = await dio.get(ApiEndpoints.tag);

      if (response.data is List) {
        List<dynamic> data = response.data;
        final tags = data.map((json) => TagModel.fromJson(json)).toList();

        return PagedResponse<TagModel>(
          data: tags,
          totalRecords: tags.length,
          pageNumber: page.pageNumber,
          pageSize: page.pageSize,
          totalPages: 1,
        );
      } else if (response.data is Map && response.data['data'] is List) {
        // دعم حالة ما إذا كانت القائمة داخل حقل data
        List<dynamic> data = response.data['data'];
        final tags = data.map((json) => TagModel.fromJson(json)).toList();
        return PagedResponse<TagModel>(
          data: tags,
          totalRecords: tags.length,
          pageNumber: page.pageNumber,
          pageSize: page.pageSize,
          totalPages: 1,
        );
      } else {
        throw Exception("تنسيق البيانات غير مدعوم من السيرفر");
      }
    } on DioException {
      rethrow;
    }
  }
}
