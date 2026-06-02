import 'package:isar/isar.dart';
import 'package:spendwise/features/auth/domain/entities/user_entity.dart';

// هذا السطر ضروري لتوليد الملف التلقائي
part 'user_model.g.dart';

@collection
class UserModel extends UserEntity {
  Id isarId = Isar.autoIncrement;

  // // ميزة: إضافة حقل الـ refreshToken هنا ليتم حفظه داخل قاعدة بيانات Isar محلياً

  UserModel({
    required super.userId,
    super.firstName,
    super.lastName,
    super.userName,
    required super.token,
    super.expiry,
    super.refreshToken, // // تعليق: استقبال الـ refreshToken وحفظه في الحقل المحلي الخاص بـ Isar
  });

  factory UserModel.fromJson(Map<dynamic, dynamic> json) {
    final dynamic userIdRaw = json["UserId"] ?? json["userId"];
    int parsedUserId = -1;
    if (userIdRaw is int) {
      parsedUserId = userIdRaw;
    } else if (userIdRaw is String) {
      parsedUserId = int.tryParse(userIdRaw) ?? -1;
    }

    final dynamic expiryRaw = json["Expiry"] ?? json["expiry"];
    DateTime? parsedExpiry;
    if (expiryRaw is DateTime) {
      parsedExpiry = expiryRaw;
    } else if (expiryRaw is String && expiryRaw.isNotEmpty) {
      parsedExpiry = DateTime.tryParse(expiryRaw);
    }

    return UserModel(
      token: (json["Token"] ?? json["token"] ?? "").toString(),
      // // ميزة: التقاط الـ RefreshToken القادم من استجابة الـ API عند تسجيل الدخول أو التجديد
      refreshToken: (json["RefreshToken"] ?? json["refreshToken"] ?? "")
          .toString(),
      firstName: (json["FirstName"] ?? json["firstName"] ?? "").toString(),
      lastName: (json["LastName"] ?? json["lastName"] ?? "").toString(),
      userName: (json["UserName"] ?? json["userName"] ?? "").toString(),
      expiry: parsedExpiry ?? DateTime.now(),
      userId: parsedUserId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "UserId": userId,
      "FirstName": firstName,
      "LastName": lastName,
      "UserName": userName,
      "Token": token,
      "RefreshToken":
          refreshToken, // // تعليق: تحويل الـ RefreshToken إلى JSON عند الحاجة
      "Expiry": expiry?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'UserModel(isarId: $isarId, userId: $userId, firstName: $firstName, lastName: $lastName, userName: $userName, token: $token, refreshToken: $refreshToken, expiry: $expiry)';
  }
}
