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

  DateTime? dateOfBirth;

  String gender = "";

  String mobileNumber = "";

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
    if (dateOfBirth == null) return null;

    final today = DateTime.now();

    int years = today.year - dateOfBirth!.year;

    if (today.month < dateOfBirth!.month ||
        (today.month == dateOfBirth!.month &&
            today.day < dateOfBirth!.day)) {
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

    mobileNumber = json["mobileNumber"] ?? "";

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

    if (json["dateOfBirth"] != null) {
      dateOfBirth = DateTime.parse(
        json["dateOfBirth"],
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

    dateOfBirth = null;

    gender = "";

    mobileNumber = "";

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
      "dateOfBirth": dateOfBirth?.toIso8601String(),
      "gender": gender,
      "mobileNumber": mobileNumber,
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