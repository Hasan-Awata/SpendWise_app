// lib/features/auth/data/repositories/user_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
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
      // محاولة التسجيل عبر السيرفر
      final user = await appUserRemoteDatasource.register(params);
      // حفظ البيانات محلياً فور النجاح
      await appUserLocalDatasource.registerLocal(user);

      return Right(user);
    } on DioException catch (e) {
      return Left(_mapDioErrorToFailure(e));
    } catch (e) {
      return Left(CacheFailure("فشل في حفظ بيانات المستخدم محلياً"));
    }
  }

  // --- Login ---
  @override
  Future<Either<Failure, UserModel>> logIn(LoginParams params) async {
    try {
      // محاولة تسجيل الدخول
      final user = await appUserRemoteDatasource.logIn(params);

      // تحديث البيانات المحلية
      await appUserLocalDatasource.registerLocal(user);

      return Right(user);
    } on DioException catch (e) {
      return Left(_mapDioErrorToFailure(e));
    } catch (e, stacktrace) {
      // // Debug: طباعة الخطأ والـ stacktrace في الـ Console لمعرفة السبب الحقيقي
      print("Error during login: $e");
      print("Stacktrace: $stacktrace");

      return Left(ServerFailure(e.toString()));
    }
  }

  // --- Logout ---
  @override
  Future<Either<Failure, Unit>> logOut() async {
    try {
      // تسجيل الخروج من السيرفر
      await appUserRemoteDatasource.logOut();
      // مسح البيانات المحلية
      await appUserLocalDatasource.logOut();
      return const Right(unit); // unit تعادل void في البرمجة الوظيفية
    } catch (e) {
      return Left(CacheFailure("حدث خطأ أثناء تسجيل الخروج"));
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
      return Left(CacheFailure("فشل في قراءة بيانات المستخدم"));
    }
  }

  // --- Get User ID ---
  @override
  Future<Either<Failure, int>> getUserId() async {
    try {
      final id = await appUserLocalDatasource.getUserId();
      return Right(id);
    } catch (e) {
      return Left(CacheFailure("فشل في الحصول على معرف المستخدم"));
    }
  }

  // --- Helpers ---

  Failure _mapDioErrorToFailure(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkFailure("لا يوجد اتصال بالإنترنت، تأكد من الشبكة");

      case DioExceptionType.badResponse:
        String message = "حدث خطأ في السيرفر (500)";
        if (e.response?.data != null) {
          if (e.response?.data is Map) {
            message = e.response?.data['message']?.toString() ?? message;
          } else {
            message = e.response?.data.toString() ?? "Error";
          }
        }
        return ServerFailure(message);

      case DioExceptionType.cancel:
        return ServerFailure("تم إلغاء الطلب");

      default:
        return ServerFailure("حدث خطأ غير متوقع، حاول لاحقاً");
    }
  }
}
