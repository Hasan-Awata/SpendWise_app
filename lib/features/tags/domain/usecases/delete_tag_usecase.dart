// // تعليق: وحدة الخدمة الخاصة بحذف الوسم نهائياً من كافة المصادر
import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/tags/data/repositories/tag_repository.dart';

class DeleteTagUsecase {
  final TagRepository tagRepository;

  DeleteTagUsecase(this.tagRepository);

  Future<Either<Failure, String>> call(TagModel tag) async {
    return await tagRepository.deleteTag(tag);
  }
}
