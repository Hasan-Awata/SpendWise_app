import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/tags/data/repositories/tag_repository.dart';
import 'package:spendwise/features/tags/domain/entities/tag_entity.dart';

// // تعليق: وحدة الخدمة لجلب الأوسمة تدعم نظام الصفحات وتتعامل مع الكيانات فقط
class GetMyTagsUsecase {
  final TagRepository tagRepository;

  GetMyTagsUsecase(this.tagRepository);

  // تم تعديل الدالة لاستقبال PageRequest وإرجاع PagedResponse من نوع TagEntity
  Future<Either<Failure, List<TagEntity>>> call() async {
    return await tagRepository.getMyTags();
  }
}
