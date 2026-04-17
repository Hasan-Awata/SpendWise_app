/*
  Implementation for TagRemoteDatasource using http with explicit logging.
*/

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:spendwise/core/network/api_endpoints.dart';
import 'package:spendwise/core/utils/current_user.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/tags/data/datasources/tag_remote_datasource.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';

class TagRemoteDatasourceImpl implements TagRemoteDatasource {
  final http.Client client;
  TagRemoteDatasourceImpl({required this.client});

  // دالة مساعدة لجلب التوكن وتجهيز الـ Headers لضمان عدم وجود خطأ 401
  Future<Map<String, String>> _getHeaders() async {
    final user = await AppUserLocalDatasourceImpl().getUser();
    final String? token;
    if (user != null) {
      token = user.token;
    } else {
      token = CurrentUser.token;
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<TagModel> addTag(TagModel tag) async {
    final url = Uri.parse("${ApiEndpoints.baseUrl}${ApiEndpoints.tag}");
    final headers = await _getHeaders();
    final body = jsonEncode(tag.toJson());

    print("Sending Tag JSON: $body to $url");

    final response = await client.post(url, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("AddTag Success: ${response.body} status : ${response.statusCode}");
      final decodedData = jsonDecode(response.body);

      // معالجة حالة ما إذا كان السيرفر يعيد البيانات داخل حقل 'data'
      if (decodedData is Map && decodedData.containsKey('data')) {
        return TagModel.fromJson(decodedData['data']);
      }
      return TagModel.fromJson(decodedData);
    } else {
      print("AddTag Error [${response.statusCode}]: ${response.body}");
      throw Exception("فشل إضافة التاج: ${response.body}");
    }
  }

  @override
  Future<void> updateTag(TagModel tag) async {
    // استخدام PATCH للتحديث الجزئي كما في الـ Wallet
    final url = Uri.parse(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.tag}/${tag.id}",
    );
    final headers = await _getHeaders();
    final body = jsonEncode(tag.toJson());

    print("Updating Tag ${tag.id} at: $url");

    final response = await client.patch(url, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 204) {
      print("UpdateTag Success");
    } else {
      print("UpdateTag Error [${response.statusCode}]: ${response.body}");
      throw Exception("فشل تحديث التاج");
    }
  }

  @override
  Future<void> deleteTag(TagModel tag) async {
    final url = Uri.parse(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.tag}/${tag.id}",
    );
    final headers = await _getHeaders();

    print("Deleting Tag: $url");

    final response = await client.delete(url, headers: headers);

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

    if (response.statusCode == 200) {
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
