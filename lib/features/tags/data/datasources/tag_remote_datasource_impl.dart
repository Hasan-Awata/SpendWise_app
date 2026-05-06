/*
  Implementation for TagRemoteDatasource using http with explicit logging.
*/

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:spendwise/core/network/api_endpoints.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/tags/data/datasources/tag_remote_datasource.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';

class TagRemoteDatasourceImpl implements TagRemoteDatasource {
  final http.Client client;
  TagRemoteDatasourceImpl({required this.client});
  final Duration timeoutDuration = const Duration(
    seconds: 15,
  ); // تحديد مدة المهلة

  Future<Map<String, String>?> _getHeaders() async {
    try {
      final user = await AppUserLocalDatasourceImpl().getUser();

      final String? token;
      if (user != null) {
        token = user.token;
        print("${user.userId} ---- ${user.token}");
      } else {
        HelperFunction.showSnackBar("Error Auth", "User Not found");
        return null;
      }
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } catch (e) {
      HelperFunction.showSnackBar("Error Auth", e.toString());
      return null;
    }
  }

  @override
  Future<TagModel?> addTag(TagModel tag) async {
    final url = Uri.parse("${ApiEndpoints.baseUrl}${ApiEndpoints.tag}");
    final headers = await _getHeaders();
    final body = jsonEncode(tag.toJson());

    print("Sending Tag JSON: $body to $url");

    final response = await client.post(url, headers: headers, body: body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print(jsonDecode(response.body));
      return TagModel.fromJson(jsonDecode(response.body));
    } else {
      print("AddTag Error [${response.statusCode}]: ${response.body}");
      throw Exception("فشل إضافة التاج: ${response.body}");
    }
  }

  @override
  Future<TagModel?> updateTag(TagModel tag) async {
    final url = Uri.parse(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.tag}/${tag.id}",
    );
    final headers = await _getHeaders();
    final body = jsonEncode(tag.toJson());

    try {
      final response = await client
          .patch(url, headers: headers, body: body)
          .timeout(timeoutDuration);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return TagModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("فشل تحديث المحفظة: رمز الحالة ${response.statusCode}");
      }
    } on TimeoutException {
      throw Exception("انتهت مهلة التحديث، يرجى المحاولة لاحقاً");
    }
  }

  @override
  Future<void> deleteTag(int id) async {
    final url = Uri.parse("${ApiEndpoints.baseUrl}${ApiEndpoints.tag}/$id");
    final headers = await _getHeaders();

    print("Deleting Tag: $url");

    final response = await client.delete(url, headers: headers);
    print("${response.body}");
    if (response.statusCode == 200 || response.statusCode == 204) {
      print("DeleteTag Success");
    } else {
      print("DeleteTag Error [${response.statusCode}]: ${response.body}");
      throw Exception("فشل حذف التاج");
    }
  }

  @override
  Future<PagedResponse<TagModel>> getMyTags(PageRequest page) async {
    final url = Uri.parse("${ApiEndpoints.baseUrl}${ApiEndpoints.tag}");
    final headers = await _getHeaders();

    print("Fetching Tags from: $url");

    final response = await client.get(url, headers: headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print("GetTags Success: تم جلب التاجات");
      final decodedData = jsonDecode(response.body);

      List<dynamic> list;
      if (decodedData is List) {
        list = decodedData;
      } else if (decodedData is Map && decodedData['data'] is List) {
        list = decodedData['data'];
      } else {
        throw Exception("تنسيق البيانات غير مدعوم");
      }

      final tags = list.map((json) => TagModel.fromJson(json)).toList();

      return PagedResponse<TagModel>(
        data: tags,
        totalRecords: tags.length,
        pageNumber: page.pageNumber,
        pageSize: page.pageSize,
        totalPages: 1,
      );
    } else {
      print("GetTags Error [${response.statusCode}]: ${response.body}");
      throw Exception("فشل جلب التاجات من السيرفر");
    }
  }
}
