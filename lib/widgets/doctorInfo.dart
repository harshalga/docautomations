

class DoctorInfo {
  final String name;
  final String specialization;
  final String clinicName;
  final String clinicAddress;
  final String contact;
  //final String? logoPath;       // For mobile/desktop
  final String? logoBase64;     // For web
  final String loginEmail  ;
  final String password;

  
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
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'specialization': specialization,
        'clinicName': clinicName,
        'clinicAddress': clinicAddress,
        'contact': contact,
        'loginEmail':loginEmail,
       'password': password,
        //'logoPath': logoPath,
        'logoBase64': logoBase64,
      };

  static DoctorInfo fromJson(Map<String, dynamic> json) => DoctorInfo(
        name: json['name'],
        specialization: json['specialization'],
        clinicName: json['clinicName'],
        clinicAddress: json['clinicAddress'],
        contact: json['contact'],
        loginEmail: json['loginEmail'],
        password: json['password'],
        //logoPath: json['logoPath'],
        logoBase64: json['logoBase64'],
      );
}
