// // تعليق: كائن لطلب صفحة محددة من البيانات من السيرفر مع تحديد حجم الصفحة ورقمها
class PageRequest {
  final int pageSize;
  final int pageNumber;

  PageRequest({
    this.pageSize = 10, // قيمة افتراضية
    this.pageNumber = 1,
  });

  // // تعليق: تحويل الطلب إلى Map لاستخدامه كـ Query Parameters في رابط الـ API
  Map<String, String> toQueryParams() {
    return {
      'PageSize': pageSize.toString(),
      'PageNumber': pageNumber.toString(),
    };
  }
}
