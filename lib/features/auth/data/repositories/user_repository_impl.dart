// // تعليق: تنفيذ مستودع المستخدم - تم التحديث ليتوافق مع أخطاء حزمة http بدلاً من Dio
import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_remote_datasource.dart';
import 'package:spendwise/features/auth/data/models/user_model.dart';
import 'package:spendwise/features/auth/domain/repositories/user_repository.dart';
import 'package:spendwise/features/auth/domain/usecases/login_params.dart';
import 'package:spendwise/features/auth/domain/usecases/signup_params.dart';

class UserRepositoryImpl implements UserRepository {
  final AppUserLocalDatasource appUserLocalDatasource;
  final AppUserRemoteDatasource appUserRemoteDatasource;

  UserRepositoryImpl({
    required this.appUserLocalDatasource,
    required this.appUserRemoteDatasource,
  });

  // --- Register ---
  @override
  Future<Either<Failure, UserModel>> register(SignupParams params) async {
    try {
      print("📡 Attempting Remote Register...");
      final user = await appUserRemoteDatasource.register(params);

      print("token is --->>>>> :${user.token}");
      print("💾 Saving User Locally...");
      await appUserLocalDatasource.registerLocal(user);

      return Right(user);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  // --- Login ---
  @override
  Future<Either<Failure, UserModel>> logIn(LoginParams params) async {
    try {
      print("📡 Attempting Remote Login...");
      final user = await appUserRemoteDatasource.logIn(params);

      print("💾 Updating Local User Data...");

      await appUserLocalDatasource.registerLocal(user);

      return Right(user);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  // --- Logout ---
  @override
  Future<Either<Failure, Unit>> logOut() async {
    try {
      print("🗑️ Clearing Local Session...");
      await appUserLocalDatasource.logOut();
      // ملاحظة: يمكن استدعاء logout من الـ Remote هنا أيضاً إذا كان السيرفر يتطلب ذلك
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure("حدث خطأ أثناء تسجيل الخروج محلياً"));
    }
  }

  // --- Get User ---
  @override
  Future<Either<Failure, UserModel>> getUser() async {
    try {
      final user = await appUserLocalDatasource.getUser();
      if (user != null) {
        return Right(user);
      } else {
        return Left(CacheFailure("لا يوجد مستخدم مسجل حالياً"));
      }
    } catch (e) {
      return Left(CacheFailure("فشل في قراءة بيانات المستخدم من الذاكرة"));
    }
  }

  // --- Get User ID ---
  @override
  Future<Either<Failure, int>> getUserId() async {
    try {
      final id = await appUserLocalDatasource.getUserId();
      if (id != null) {
        return Right(id);
      }
      return Left(CacheFailure("لا يوجد مستخدم مسجل حالياً"));
    } catch (e) {
      return Left(CacheFailure("فشل في الحصول على معرف المستخدم"));
    }
  }

  // --- Exception Handling (بديل لـ DioError) ---
  @override
  Future<Either<Failure, UserModel>> getUserByUsername(String username) async {
    try {
      final user = await appUserRemoteDatasource.getUserByUsername(username);
      return Right(user);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  Failure _handleException(dynamic e) {
    print("❌ Auth Repository Exception: $e");

    if (e is SocketException) {
      return NetworkFailure("لا يوجد اتصال بالإنترنت، تأكد من الشبكة");
    }

    if (e is TimeoutException) {
      return NetworkFailure("انتهت مهلة الطلب، يرجى المحاولة مرة أخرى");
    }

    if (e is FormatException) {
      return ServerFailure("خطأ في تحليل البيانات المستلمة من السيرفر");
    }

    // في حال تم رمي Exception يدوي من الـ Datasource (مثل خطأ 401 أو 500)
    if (e is Exception) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      return ServerFailure(errorMessage);
    }

    return ServerFailure("حدث خطأ غير متوقع: ${e.toString()}");
  }
}
