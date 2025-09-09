

class DoctorInfo {
  final String name;
  final String specialization;
  final String clinicName;
  final String clinicAddress;
  final String contact;
  //final String? logoPath;       // For mobile/desktop
  final String? logoBase64;     // For web
  final String loginEmail  ;
  final String? password;
  final bool printLetterhead;     
  final int prescriptionCount; 
  final DateTime? licensedOnDate;          // ✅ new
  final DateTime? nextRenewalDate;         // ✅ new
  final DateTime? firstTimeRegistrationDate; // ✅ new

  
  DoctorInfo({
    required this.name,
    required this.specialization,
    required this.clinicName,
    required this.clinicAddress,
    required this.contact,
    required this.loginEmail,
    required this.password,
    //this.logoPath,
    this.logoBase64,
    this.printLetterhead = true,   
    this.prescriptionCount = 0,    
    this.licensedOnDate,
    this.nextRenewalDate,
    this.firstTimeRegistrationDate,
    
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'specialization': specialization,
        'clinicName': clinicName,
        'clinicAddress': clinicAddress,
        'contact': contact,
        'loginEmail':loginEmail,
       if (password != null) 'password': password,  // ✅ Only include if present
        //'logoPath': logoPath,
        'logoBase64': logoBase64,
        'printLetterhead': printLetterhead,
      'prescriptionCount': prescriptionCount,
      'licensedOnDate': licensedOnDate?.toIso8601String(),
      'nextRenewalDate': nextRenewalDate?.toIso8601String(),
      'firstTimeRegistrationDate': firstTimeRegistrationDate?.toIso8601String(),
      };

  static DoctorInfo fromJson(Map<String, dynamic> json) => DoctorInfo(
        name: json['name'],
        specialization: json['specialization'],
        clinicName: json['clinicName'],
        clinicAddress: json['clinicAddress'],
        contact: json['contact'],
        loginEmail: json['loginEmail'],
        password: json['password'],   // ✅ Safe: null if not returned
        //logoPath: json['logoPath'],
        logoBase64: json['logoBase64'],
         printLetterhead: json['printLetterhead'] ?? true,
      prescriptionCount: json['prescriptionCount'] ?? 0,
      licensedOnDate: json['licensedOnDate'] != null
          ? DateTime.parse(json['licensedOnDate'])
          : null,
      nextRenewalDate: json['nextRenewalDate'] != null
          ? DateTime.parse(json['nextRenewalDate'])
          : null,
      firstTimeRegistrationDate: json['firstTimeRegistrationDate'] != null
          ? DateTime.parse(json['firstTimeRegistrationDate'])
          : null,
      );
       /// ✅ copyWith method
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
      firstTimeRegistrationDate: firstTimeRegistrationDate ?? this.firstTimeRegistrationDate,
    );
  }
  
}
