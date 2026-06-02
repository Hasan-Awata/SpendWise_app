import 'package:spendwise/core/network/api_endpoints.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/tags/data/datasources/tag_remote_datasource.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';

class TagRemoteDatasourceImpl implements TagRemoteDatasource {
  final NetworkService network;

  TagRemoteDatasourceImpl({required this.network});

  // =========================
  // ADD TAG
  // =========================
  @override
  Future<TagModel?> addTag(TagModel tag) async {
    final result = await network.request(
      endpoint: ApiEndpoints.tag,
      method: "POST",
      body: tag.toJson(),
    );

    return TagModel.fromJson(result);
  }

  // =========================
  // UPDATE TAG
  // =========================
  @override
  Future<TagModel?> updateTag(TagModel tag) async {
    final result = await network.request(
      endpoint: "${ApiEndpoints.tag}/${tag.id}",
      method: "PATCH",
      body: tag.toJson(),
    );

    return TagModel.fromJson(result);
  }

  // =========================
  // DELETE TAG
  // =========================
  @override
  Future<bool> deleteTag(int id) async {
    try {
      await network.request(
        endpoint: "${ApiEndpoints.tag}/$id",
        method: "DELETE",
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  // =========================
  // GET TAGS
  // =========================
  @override
  Future<List<TagModel>?> getMyTags() async {
    final result = await network.request(
      endpoint: ApiEndpoints.tag,
      method: "GET",
    );

    final List<dynamic> list = (result is Map && result['data'] is List)
        ? result['data']
        : result;

    return list.map((json) => TagModel.fromJson(json)).toList();
  }
}
