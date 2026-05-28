



class DoctorInfo {
  final String name;
  final String specialization;
  final String clinicName;
  final String clinicAddress;
  final String contact;
  final String? logoBase64;
  final String loginEmail;
  final String? password;

  final bool printLetterhead;
  final int prescriptionCount;

  final DateTime? licensedOnDate;
  final DateTime? nextRenewalDate;
  final DateTime? firstTimeRegistrationDate;

  final bool isTrialActive;
  final String planName;
  final String planDisplayName;
  final String planDescription;

  DoctorInfo({
    required this.name,
    required this.specialization,
    required this.clinicName,
    required this.clinicAddress,
    required this.contact,
    required this.loginEmail,
    this.password,
    this.logoBase64,
    this.printLetterhead = true,
    this.prescriptionCount = 0,
    this.licensedOnDate,
    this.nextRenewalDate,
    this.firstTimeRegistrationDate,
    this.isTrialActive = true,
    this.planName = "trial",
    this.planDisplayName = "Trial Plan",
    this.planDescription = "Free trial with limited features",
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'specialization': specialization,
        'clinicName': clinicName,
        'clinicAddress': clinicAddress,
        'contact': contact,
        'loginEmail': loginEmail,
        if (password != null) 'password': password,
        'logoBase64': logoBase64,
        'printLetterhead': printLetterhead,
        'prescriptionCount': prescriptionCount,
        'licensedOnDate': licensedOnDate?.toIso8601String(),
        'nextRenewalDate': nextRenewalDate?.toIso8601String(),
        'firstTimeRegistrationDate':
            firstTimeRegistrationDate?.toIso8601String(),
        'isTrialActive': isTrialActive,
        'planName': planName,
        'planDisplayName': planDisplayName,
        'planDescription': planDescription,
      };

  factory DoctorInfo.fromJson(Map<String, dynamic> json) {
    return DoctorInfo(
      name: json['name'] ?? '',
      specialization: json['specialization'] ?? '',
      clinicName: json['clinicName'] ?? '',
      clinicAddress: json['clinicAddress'] ?? '',
      contact: json['contact'] ?? '',
      loginEmail: json['loginEmail'] ?? '',
      password: json['password'],
      logoBase64: json['logoBase64'],
      printLetterhead: json['printLetterhead'] ?? true,
      prescriptionCount: json['prescriptionCount'] ?? 0,
      licensedOnDate: json['licensedOnDate'] != null
          ? DateTime.tryParse(json['licensedOnDate'])
          : null,
      nextRenewalDate: json['nextRenewalDate'] != null
          ? DateTime.tryParse(json['nextRenewalDate'])
          : null,
      firstTimeRegistrationDate:
          json['firstTimeRegistrationDate'] != null
              ? DateTime.tryParse(json['firstTimeRegistrationDate'])
              : null,
      isTrialActive: json['isTrialActive'] ?? true,
      planName: json['planName'] ?? 'trial',
      planDisplayName: json['planDisplayName'] ?? 'Trial Plan',
      planDescription: json['planDescription'] ??
          'Free trial with limited features',
    );
  }

  DoctorInfo copyWith({
    String? name,
    String? specialization,
    String? clinicName,
    String? clinicAddress,
    String? contact,
    String? loginEmail,
    String? password,
    String? logoBase64,
    bool? printLetterhead,
    int? prescriptionCount,
    DateTime? licensedOnDate,
    DateTime? nextRenewalDate,
    DateTime? firstTimeRegistrationDate,
    bool? isTrialActive,
    String? planName,
    String? planDisplayName,
    String? planDescription,
  }) {
    return DoctorInfo(
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      clinicName: clinicName ?? this.clinicName,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      contact: contact ?? this.contact,
      loginEmail: loginEmail ?? this.loginEmail,
      password: password ?? this.password,
      logoBase64: logoBase64 ?? this.logoBase64,
      printLetterhead: printLetterhead ?? this.printLetterhead,
      prescriptionCount: prescriptionCount ?? this.prescriptionCount,
      licensedOnDate: licensedOnDate ?? this.licensedOnDate,
      nextRenewalDate: nextRenewalDate ?? this.nextRenewalDate,
      firstTimeRegistrationDate:
          firstTimeRegistrationDate ?? this.firstTimeRegistrationDate,
      isTrialActive: isTrialActive ?? this.isTrialActive,
      planName: planName ?? this.planName,
      planDisplayName: planDisplayName ?? this.planDisplayName,
      planDescription: planDescription ?? this.planDescription,
    );
  }
}