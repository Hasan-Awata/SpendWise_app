// // تعليق: وحدة الخدمة المسؤولة عن تحديث بيانات الوسم ومزامنته مع السيرفر
import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/tags/data/repositories/tag_repository.dart';

class UpdateTagUsecase {
  final TagRepository tagRepository;

  UpdateTagUsecase(this.tagRepository);

  Future<Either<Failure, Unit>> call(TagModel tag) async {
    return await tagRepository.updateTag(tag);
  }
}
