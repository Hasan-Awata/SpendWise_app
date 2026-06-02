class TokenDto {
  final String accessToken;
  final String refreshToken;

  TokenDto({required this.accessToken, required this.refreshToken});

  // تحويل البيانات إلى Map لإرسالها كـ JSON
  Map<String, dynamic> toJson() {
    return {'accessToken': accessToken, 'refreshToken': refreshToken};
  }

  // استقبال البيانات الجديدة بعد التجديد
  factory TokenDto.fromJson(Map<String, dynamic> json) {
    return TokenDto(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'] ?? '',
    );
  }
}
