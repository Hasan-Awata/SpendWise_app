// // // تعليق: وحدة الخدمة المسؤولة عن رفع البيانات المعلقة التي تم إنشاؤها أثناء انقطاع الإنترنت
// import 'package:dartz/dartz.dart';
// import 'package:spendwise/core/error/failure.dart';
// import 'package:spendwise/features/tags/data/repositories/tag_repository.dart';

// class SyncPendingTagsUsecase {
//   final TagRepository tagRepository;

//   SyncPendingTagsUsecase(this.tagRepository);

//   Future<Either<Failure, Unit>> call() async {
//     return await tagRepository.syncPendingTags();
//   }
// }
