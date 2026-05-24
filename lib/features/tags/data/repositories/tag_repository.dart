// // تعليق: عقد المستودع الخاص بالأوسمة يحدد العمليات الأساسية باستخدام الكيانات
import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/tags/domain/entities/tag_entity.dart';

abstract class TagRepository {
  Future<Either<Failure, String>> addTag(TagEntity tag);
  Future<Either<Failure, List<TagEntity>>> getMyTags();
  Future<Either<Failure, String>> deleteTag(TagEntity tag);
  Future<Either<Failure, String>> updateTag(TagEntity tag);
}
