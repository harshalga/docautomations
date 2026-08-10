import 'package:docautomations/services/image/procesed_image.dart';

class DoctorRegistrationRequest {
  //---------------------------------------------------------------------------
  // Personal Information
  //---------------------------------------------------------------------------

  final String doctorName;

  final String specialization;

  final String qualification;

  //---------------------------------------------------------------------------
  // Clinic Information
  //---------------------------------------------------------------------------

  final String clinicName;

  final String clinicAddress;

  final String city;

  final String state;

  final String pincode;

  //---------------------------------------------------------------------------
  // Contact Information
  //---------------------------------------------------------------------------

  final String contact;

  final String alternateContact;

  final String website;

  //---------------------------------------------------------------------------
  // Login Information
  //---------------------------------------------------------------------------

  final String loginEmail;

  final String password;

  //---------------------------------------------------------------------------
  // Medical Registration
  //---------------------------------------------------------------------------

  final String medicalRegistrationNumber;

  final String registrationAuthority;

  final String countryId;

  //---------------------------------------------------------------------------
  // Doctor Logo (Optional)
  //---------------------------------------------------------------------------

  final ProcessedImage? logo;

  //---------------------------------------------------------------------------
  // Constructor
  //---------------------------------------------------------------------------

  const DoctorRegistrationRequest({
    this.doctorName = '',
    this.specialization = '',
    this.qualification = '',
    this.clinicName = '',
    this.clinicAddress = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.contact = '',
    this.alternateContact = '',
    this.website = '',
    this.loginEmail = '',
    this.password = '',
    this.medicalRegistrationNumber = '',
    this.registrationAuthority = '',
    this.countryId = '',
    this.logo,
  });

  //---------------------------------------------------------------------------
  // Copy With
  //---------------------------------------------------------------------------

  DoctorRegistrationRequest copyWith({
    String? doctorName,
    String? specialization,
    String? qualification,
    String? clinicName,
    String? clinicAddress,
    String? city,
    String? state,
    String? pincode,
    String? contact,
    String? alternateContact,
    String? website,
    String? loginEmail,
    String? password,
    String? medicalRegistrationNumber,
    String? registrationAuthority,
    String? countryId,
    ProcessedImage? logo,
  }) {
    return DoctorRegistrationRequest(
      doctorName:
          doctorName ?? this.doctorName,
      specialization:
          specialization ?? this.specialization,
      qualification:
          qualification ?? this.qualification,
      clinicName:
          clinicName ?? this.clinicName,
      clinicAddress:
          clinicAddress ?? this.clinicAddress,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      contact: contact ?? this.contact,
      alternateContact:
          alternateContact ??
              this.alternateContact,
      website: website ?? this.website,
      loginEmail:
          loginEmail ?? this.loginEmail,
      password: password ?? this.password,
      medicalRegistrationNumber:
          medicalRegistrationNumber ??
              this.medicalRegistrationNumber,
      registrationAuthority:
          registrationAuthority ??
              this.registrationAuthority,
      countryId:
          countryId ?? this.countryId,
      logo: logo ?? this.logo,
    );
  }

  //---------------------------------------------------------------------------
  // JSON Serialization
  //---------------------------------------------------------------------------

  factory DoctorRegistrationRequest.fromJson(
      Map<String, dynamic> json) {
    return DoctorRegistrationRequest(
      doctorName: json["name"] ?? "",
      specialization:
          json["specialization"] ?? "",
      qualification:
          json["qualification"] ?? "",
      clinicName:
          json["clinicName"] ?? "",
      clinicAddress:
          json["clinicAddress"] ?? "",
      city: json["city"] ?? "",
      state: json["state"] ?? "",
      pincode: json["pincode"] ?? "",
      contact: json["contact"] ?? "",
      alternateContact:
          json["alternateContact"] ?? "",
      website: json["website"] ?? "",
      loginEmail:
          json["loginEmail"] ?? "",
      password: json["password"] ?? "",
      medicalRegistrationNumber:
          json["medicalRegistrationNumber"] ??
              "",
      registrationAuthority:
          json["registrationAuthority"] ??
              "",
      countryId:
          json["countryId"] ?? "",
      logo: json["logo"] != null
          ? ProcessedImage.fromJson(
              json["logo"],
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": doctorName,
      "specialization": specialization,
      "qualification": qualification,
      "clinicName": clinicName,
      "clinicAddress": clinicAddress,
      "city": city,
      "state": state,
      "pincode": pincode,
      "contact": contact,
      "alternateContact": alternateContact,
      "website": website,
      "loginEmail":
          loginEmail.trim().toLowerCase(),
      "password": password,
      "medicalRegistrationNumber":
          medicalRegistrationNumber
              .trim()
              .toUpperCase(),
      "registrationAuthority":
          registrationAuthority,
      "countryId": countryId,
      "logo": logo?.toJson(),
    };
  }

  //---------------------------------------------------------------------------
  // Validation Helpers
  //---------------------------------------------------------------------------

  bool get isValid =>
      doctorName.trim().isNotEmpty &&
      qualification.trim().isNotEmpty &&
      clinicName.trim().isNotEmpty &&
      clinicAddress.trim().isNotEmpty &&
      contact.trim().isNotEmpty &&
      loginEmail.trim().isNotEmpty &&
      password.trim().isNotEmpty &&
      medicalRegistrationNumber
          .trim()
          .isNotEmpty &&
      countryId.trim().isNotEmpty;
}