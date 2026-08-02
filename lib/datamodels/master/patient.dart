class Patient {
  final String id;
  final String ppid;

  final String firstName;
  final String middleName;
  final String lastName;

  final DateTime? dateOfBirth;

  final String gender;

  final String mobileNumber;

  final String email;

  final String addressLine1;
  final String addressLine2;
  final String city;  
  final String district;
  final String state;
  final String countryid;
  final String pinCode; 
  const Patient({
    required this.id,
    required this.ppid,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    this.dateOfBirth,
    required this.gender,
    required this.mobileNumber,
    required this.email,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.district,
    required this.state,
    required this.countryid,
    required this.pinCode,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json["_id"] ?? "",

      ppid: json["ppid"] ?? "",

      firstName: json["firstName"] ?? "",

      middleName: json["middleName"] ?? "",

      lastName: json["lastName"] ?? "",

      dateOfBirth: json["dateOfBirth"] != null
          ? DateTime.parse(json["dateOfBirth"])
          : null,

      gender: json["gender"] ?? "",

      mobileNumber: json["mobileNumber"] ?? "",

      email: json["email"] ?? "",

      addressLine1: json["addressLine1"] ?? "",
      addressLine2: json["addressLine2"] ?? "",
      city: json["city"] ?? "",
      district: json["district"] ?? "",
      state: json["state"] ?? "",
      countryid: json["countryid"] ?? "",
      pinCode: json["pinCode"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "ppid": ppid,
      "firstName": firstName,
      "middleName": middleName,
      "lastName": lastName,
      "dateOfBirth": dateOfBirth?.toIso8601String(),
      "gender": gender,
      "mobileNumber": mobileNumber,
      "email": email,
      "addressLine1": addressLine1,
      "addressLine2": addressLine2,
      "city": city,
      "district": district,
      "state": state,
      "countryid": countryid,
      "pinCode": pinCode,
    };
  }

  String get fullName =>
      "$firstName $middleName $lastName"
          .replaceAll(RegExp(r'\s+'), " ")
          .trim();
}