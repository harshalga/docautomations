import 'package:flutter/foundation.dart';

class PatientViewModel extends ChangeNotifier {
  //---------------------------------------------------------------------------
  // Identity
  //---------------------------------------------------------------------------

  String patientId = "";
  String patientDoctorId = "";
  String ppid = "";

  //---------------------------------------------------------------------------
  // Patient Details
  //---------------------------------------------------------------------------

  String firstName = "";
  String middleName = "";
  String lastName = "";

  DateTime? dob;

  String gender = "";

  String mobile = "";

  String email = "";

  //---------------------------------------------------------------------------
  // Address
  //---------------------------------------------------------------------------

  String addressLine1 = "";

  String addressLine2 = "";

  String city = "";

  String district = "";

  String state = "";

  String country = "";

  String countryId = "";

  String pinCode = "";

  //---------------------------------------------------------------------------
  // Medical
  //---------------------------------------------------------------------------

  String bloodGroup = "";

  String allergies = "";

  String chronicDiseases = "";

  //---------------------------------------------------------------------------
  // Derived Properties
  //---------------------------------------------------------------------------

  String get fullName {
    return [
      firstName,
      middleName,
      lastName,
    ].where((e) => e.trim().isNotEmpty).join(" ");
  }

  int? get age {
    if (dob == null) return null;

    final today = DateTime.now();

    int years = today.year - dob!.year;

    if (today.month < dob!.month ||
        (today.month == dob!.month &&
            today.day < dob!.day)) {
      years--;
    }

    return years;
  }

  //---------------------------------------------------------------------------
  // Populate
  //---------------------------------------------------------------------------

  void populateFromJson(Map<String, dynamic> json) {
    patientId = json["_id"] ?? "";

    patientDoctorId = json["patientDoctorId"] ?? "";

    ppid = json["ppid"] ?? "";

    firstName = json["firstName"] ?? "";

    middleName = json["middleName"] ?? "";

    lastName = json["lastName"] ?? "";

    gender = json["gender"] ?? "";

    mobile = json["mobile"] ?? "";

    email = json["email"] ?? "";

    addressLine1 = json["addressLine1"] ?? "";

    addressLine2 = json["addressLine2"] ?? "";

    city = json["city"] ?? "";

    district = json["district"] ?? "";

    state = json["state"] ?? "";

    country = json["country"] ?? "";

    pinCode = json["pinCode"] ?? "";

    bloodGroup = json["bloodGroup"] ?? "";

    allergies = json["allergies"] ?? "";

    chronicDiseases = json["chronicDiseases"] ?? "";

    if (json["dob"] != null) {
      dob = DateTime.parse(
        json["dob"],
      );
    }

    notifyListeners();
  }

  //---------------------------------------------------------------------------
  // Clear
  //---------------------------------------------------------------------------

  void clear() {
    patientId = "";
    patientDoctorId = "";
    ppid = "";

    firstName = "";
    middleName = "";
    lastName = "";

    dob = null;

    gender = "";

    mobile = "";

    email = "";

    addressLine1 = "";
    addressLine2 = "";
    city = "";
    district = "";
    state = "";
    country = "";
    pinCode = "";

    bloodGroup = "";
    allergies = "";
    chronicDiseases = "";

    notifyListeners();
  }

  //---------------------------------------------------------------------------
  // Convert to JSON
  //---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      "patientId": patientId,
      "patientDoctorId": patientDoctorId,
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
      "district": district,
      "state": state,
      "country": country,
      "pinCode": pinCode,
      "bloodGroup": bloodGroup,
      "allergies": allergies,
      "chronicDiseases": chronicDiseases,
    };
  }
}