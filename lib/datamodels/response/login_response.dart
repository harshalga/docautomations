class LoginResponse {
  final String accessToken;

  final String refreshToken;

  final DateTime accessTokenExpiry;

  final DateTime refreshTokenExpiry;

  final bool subscriptionActive;

  final bool trialActive;

  final int prescriptionCount;

  final DateTime? trialEndDate;

  final DateTime? subscriptionExpiry;

  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiry,
    required this.refreshTokenExpiry,
    required this.subscriptionActive,
    required this.trialActive,
    required this.prescriptionCount,
    this.trialEndDate,
    this.subscriptionExpiry,
  });

  factory LoginResponse.fromJson(
      Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json["accessToken"] ?? "",

      refreshToken: json["refreshToken"] ?? "",

      accessTokenExpiry:
          DateTime.parse(json["accessTokenExpiry"]),

      refreshTokenExpiry:
          DateTime.parse(json["refreshTokenExpiry"]),

      subscriptionActive:
          json["subscriptionActive"] ?? false,

      trialActive:
          json["trialActive"] ?? false,

      prescriptionCount:
          json["prescriptionCount"] ?? 0,

      trialEndDate:
          json["trialEndDate"] != null
              ? DateTime.parse(json["trialEndDate"])
              : null,

      subscriptionExpiry:
          json["subscriptionExpiry"] != null
              ? DateTime.parse(
                  json["subscriptionExpiry"],
                )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "accessToken": accessToken,
      "refreshToken": refreshToken,
      "accessTokenExpiry":
          accessTokenExpiry.toIso8601String(),
      "refreshTokenExpiry":
          refreshTokenExpiry.toIso8601String(),
      "subscriptionActive":
          subscriptionActive,
      "trialActive": trialActive,
      "prescriptionCount":
          prescriptionCount,
      "trialEndDate":
          trialEndDate?.toIso8601String(),
      "subscriptionExpiry":
          subscriptionExpiry?.toIso8601String(),
    };
  }

  bool get isLoggedIn =>
      accessToken.isNotEmpty &&
      refreshToken.isNotEmpty;
}