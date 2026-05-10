import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/tags/data/repositories/tag_repository.dart';
import 'package:spendwise/features/tags/domain/entities/tag_entity.dart';

// // تعليق: وحدة الخدمة لجلب الأوسمة تدعم نظام الصفحات وتتعامل مع الكيانات فقط
class GetMyTagsUsecase {
  final TagRepository tagRepository;

  GetMyTagsUsecase(this.tagRepository);

  // تم تعديل الدالة لاستقبال PageRequest وإرجاع PagedResponse من نوع TagEntity
  Future<Either<Failure, PagedResponse<TagEntity>>> call(
    PageRequest params,
  ) async {
    return await tagRepository.getMyTags(params);
  }
}
