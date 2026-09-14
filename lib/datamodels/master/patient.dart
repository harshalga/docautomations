class Patient {
  final String id;
  final String ppid;

  final String firstName;
  final String middleName;
  final String lastName;

  final DateTime? dob;

  final String gender;

  final String mobile;

  final String email;

  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;

  final String countryId;

  final String pinCode;

  const Patient({
    required this.id,
    required this.ppid,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    this.dob,
    required this.gender,
    required this.mobile,
    required this.email,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.countryId,
    required this.pinCode,
  });

  //-------------------------------------------------------------------------
  // FROM JSON
  //-------------------------------------------------------------------------

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json["_id"]?.toString() ?? "",

      ppid: json["ppid"]?.toString() ?? "",

      firstName: json["firstName"]?.toString() ?? "",

      middleName: json["middleName"]?.toString() ?? "",

      lastName: json["lastName"]?.toString() ?? "",

      dob: json["dob"] != null
          ? DateTime.tryParse(json["dob"].toString())
          : null,

      gender: json["gender"]?.toString() ?? "",

      mobile: json["mobile"]?.toString() ?? "",

      email: json["email"]?.toString() ?? "",

      addressLine1:
          json["addressLine1"]?.toString() ?? "",

      addressLine2:
          json["addressLine2"]?.toString() ?? "",

      city: json["city"]?.toString() ?? "",

      state: json["state"]?.toString() ?? "",

      countryId:
          json["countryId"]?.toString() ?? "",

      pinCode:
          json["pinCode"]?.toString() ?? "",
    );
  }

  //-------------------------------------------------------------------------
  // TO JSON
  //-------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "ppid": ppid,
      "firstName": firstName,
      "middleName": middleName,
      "lastName": lastName,
      "dob": dob?.toIso8601String(),
      "gender": gender,
      "mobile": mobile,
      "email": email,
      "addressLine1": addressLine1,
      "addressLine2": addressLine2,
      "city": city,
      "state": state,
      "countryId": countryId,
      "pinCode": pinCode,
    };
  }

  //-------------------------------------------------------------------------
  // FULL NAME
  //-------------------------------------------------------------------------

  String get fullName =>
      "$firstName $middleName $lastName"
          .replaceAll(RegExp(r"\s+"), " ")
          .trim();
}

