// // تعليق: عقد المستودع الخاص بالأوسمة يحدد العمليات الأساسية باستخدام الكيانات
import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';

abstract class TagRepository {
  Future<Either<Failure, String>> addTag(TagModel tag);
  Future<Either<Failure, PagedResponse<TagModel>>> getMyTags(PageRequest page);
  Future<Either<Failure, String>> deleteTag(TagModel tag);
  Future<Either<Failure, Unit>> updateTag(TagModel tag);
  Future<Either<Failure, Unit>>
  syncPendingTags(); // مضافة لدعم المزامنة اللاحقة
}
