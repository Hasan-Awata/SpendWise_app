import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/tags/data/repositories/tag_repository.dart';
import 'package:spendwise/features/tags/domain/entities/tag_entity.dart';

class UpdateTagUsecase {
  final TagRepository tagRepository;

  UpdateTagUsecase(this.tagRepository);

  Future<Either<Failure, String>> call(TagEntity tag) async {
    return await tagRepository.updateTag(tag);
  }
}
