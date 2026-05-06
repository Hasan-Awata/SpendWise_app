// // تعليق: وحدة الخدمة لإضافة وسم جديد تتعامل مع الكيانات لضمان استقلالية طبقة الـ Domain
import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/tags/data/repositories/tag_repository.dart';

class AddTagUsecase {
  final TagRepository tagRepository;

  AddTagUsecase(this.tagRepository);

  // التغيير هنا: استقبال TagEntity بدلاً من TagModel لفك الارتباط بطبقة البيانات
  Future<Either<Failure, String>> call(TagModel tag) async {
    return await tagRepository.addTag(tag);
  }
}
