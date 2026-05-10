import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/tags/data/repositories/tag_repository.dart';
import 'package:spendwise/features/tags/domain/entities/tag_entity.dart';

class AddTagUsecase {
  final TagRepository tagRepository;

  AddTagUsecase(this.tagRepository);

  // التغيير هنا: استقبال TagEntity بدلاً من TagModel لفك الارتباط بطبقة البيانات
  Future<Either<Failure, String>> call(TagEntity tag) async {
    return await tagRepository.addTag(tag);
  }
}
