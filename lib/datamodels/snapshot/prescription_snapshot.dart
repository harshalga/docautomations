import 'package:docautomations/datamodels/master/patient.dart';
import 'package:docautomations/datamodels/prescriptionData.dart';

/// ===========================================================================
/// Prescription Snapshot
///
/// This is the complete immutable object that gets encrypted and stored in
/// GeneratedPrescDetails.encryptedPrescription.
///
/// It contains:
///   - Doctor information at the time of prescription
///   - Patient information at the time of prescription
///   - Clinic information at the time of prescription
///   - Prescription information
///   - Layout/printing configuration used for the prescription
/// ===========================================================================
class PrescriptionSnapshot {
  final DoctorSnapshot doctor;

  final PatientSnapshot patient;

  final ClinicSnapshot clinic;

  final PrescriptionSnapshotData prescription;

  final LayoutSnapshot layout;

  const PrescriptionSnapshot({
    required this.doctor,
    required this.patient,
    required this.clinic,
    required this.prescription,
    required this.layout,
  });

  //===========================================================================
  // From JSON
  //===========================================================================

  factory PrescriptionSnapshot.fromJson(
    Map<String, dynamic> json,
  ) {
    return PrescriptionSnapshot(
      doctor: DoctorSnapshot.fromJson(
        json["doctor"] ?? {},
      ),
      patient: PatientSnapshot.fromJson(
        json["patient"] ?? {},
      ),
      clinic: ClinicSnapshot.fromJson(
        json["clinic"] ?? {},
      ),
      prescription: PrescriptionSnapshotData.fromJson(
        json["prescription"] ?? {},
      ),
      layout: LayoutSnapshot.fromJson(
        json["layout"] ?? {},
      ),
    );
  }

  //===========================================================================
  // To JSON
  //===========================================================================

  Map<String, dynamic> toJson() {
    return {
      "doctor": doctor.toJson(),
      "patient": patient.toJson(),
      "clinic": clinic.toJson(),
      "prescription": prescription.toJson(),
      "layout": layout.toJson(),
    };
  }
}


/// ===========================================================================
/// Doctor Snapshot
/// ===========================================================================

class DoctorSnapshot {
  final String doctorName;

  final String qualification;

  final String specialization;

  final String registrationNumber;

  final String mobileNumber;

  final String email;

  const DoctorSnapshot({
    required this.doctorName,
    required this.qualification,
    required this.specialization,
    required this.registrationNumber,
    required this.mobileNumber,
    required this.email,
  });

  //===========================================================================
  // From JSON
  //===========================================================================

  factory DoctorSnapshot.fromJson(
    Map<String, dynamic> json,
  ) {
    return DoctorSnapshot(
      doctorName:
          json["doctorName"] ?? "",

      qualification:
          json["qualification"] ?? "",

      specialization:
          json["specialization"] ?? "",

      registrationNumber:
          json["registrationNumber"] ?? "",

      mobileNumber:
          json["mobileNumber"] ?? "",

      email:
          json["email"] ?? "",
    );
  }

  //===========================================================================
  // To JSON
  //===========================================================================

  Map<String, dynamic> toJson() {
    return {
      "doctorName": doctorName,
      "qualification": qualification,
      "specialization": specialization,
      "registrationNumber": registrationNumber,
      "mobileNumber": mobileNumber,
      "email": email,
    };
  }
}


/// ===========================================================================
/// Clinic Snapshot
/// ===========================================================================

class ClinicSnapshot {
  final String clinicName;

  final String clinicAddress;

  final String city;

  final String state;

  final String country;

  final String pinCode;

  const ClinicSnapshot({
    required this.clinicName,
    required this.clinicAddress,
    required this.city,
    required this.state,
    required this.country,
    required this.pinCode,
  });

  //===========================================================================
  // From JSON
  //===========================================================================

  factory ClinicSnapshot.fromJson(
    Map<String, dynamic> json,
  ) {
    return ClinicSnapshot(
      clinicName:
          json["clinicName"] ?? "",

      clinicAddress:
          json["clinicAddress"] ?? "",

      city:
          json["city"] ?? "",

      state:
          json["state"] ?? "",

      country:
          json["country"] ?? "",

      pinCode:
          json["pinCode"] ?? "",
    );
  }

  //===========================================================================
  // To JSON
  //===========================================================================

  Map<String, dynamic> toJson() {
    return {
      "clinicName": clinicName,
      "clinicAddress": clinicAddress,
      "city": city,
      "state": state,
      "country": country,
      "pinCode": pinCode,
    };
  }
}


/// ===========================================================================
/// Patient Snapshot
/// ===========================================================================

class PatientSnapshot {
  final String ppid;
  final String firstName;
  final String middleName;
  final String lastName;
  final DateTime? dob;
  final int ageAtVisit;
  final String gender;
  final String mobile;
  final String addressLine1;
  final String addressLine2;

  // Country information
  final String countryId;
  final String country;

  final String pinCode;

  const PatientSnapshot({
    required this.ppid,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    this.dob,
    required this.ageAtVisit,
    required this.gender,
    required this.mobile,
    required this.addressLine1,
    required this.addressLine2,
    required this.countryId,
    required this.country,
    required this.pinCode,
  });

  //===========================================================================
  // From JSON
  //===========================================================================

  factory PatientSnapshot.fromJson(
    Map<String, dynamic> json,
  ) {
    return PatientSnapshot(
      ppid:
          json["ppid"] ?? "",

      firstName:
          json["firstName"] ?? "",

      middleName:
          json["middleName"] ?? "",

      lastName:
          json["lastName"] ?? "",

      dob:
          json["dob"] != null
              ? DateTime.tryParse(
                  json["dob"].toString(),
                )
              : null,

      ageAtVisit:
          json["ageAtVisit"] ?? 0,

      gender:
          json["gender"] ?? "",

      mobile:
          json["mobile"] ?? "",

      addressLine1:
          json["addressLine1"] ?? "",

      addressLine2:
          json["addressLine2"] ?? "",

      country:
          json["country"] ?? "",

      countryId:
          json["countryId"] ?? "",

      pinCode:
          json["pinCode"] ?? "",
    );
  }

  factory PatientSnapshot.fromPatient({
  required Patient patient,
  required String country,
  required int ageAtVisit,
}) {
  return PatientSnapshot(
    ppid: patient.ppid,

    firstName: patient.firstName,
    middleName: patient.middleName,
    lastName: patient.lastName,

    dob: patient.dob,

    ageAtVisit: ageAtVisit,

    gender: patient.gender,

    mobile: patient.mobile,

    addressLine1: patient.addressLine1,
    addressLine2: patient.addressLine2,

    countryId: patient.countryId,
    country: country,

    pinCode: patient.pinCode,
  );
}

  //===========================================================================
  // To JSON
  //===========================================================================

  Map<String, dynamic> toJson() {
  return {
    "ppid": ppid,
    "firstName": firstName,
    "middleName": middleName,
    "lastName": lastName,
    "dob": dob?.toIso8601String(),
    "ageAtVisit": ageAtVisit,
    "gender": gender,
    "mobile": mobile,
    "addressLine1": addressLine1,
    "addressLine2": addressLine2,

    "countryId": countryId,
    "country": country,

    "pinCode": pinCode,
  };
}

  //===========================================================================
  // Full Name
  //===========================================================================

  String get fullName =>
      "$firstName $middleName $lastName"
          .replaceAll(
            RegExp(r'\s+'),
            " ",
          )
          .trim();
}


/// ===========================================================================
/// Prescription Snapshot Data
/// ===========================================================================

class PrescriptionSnapshotData {
  final String chiefComplaint;

  final String examination;

  final String diagnosis;

  final String advice;

  final String remarks;

  final DateTime? followUpDate;

  final List<Prescriptiondata> medicines;

  const PrescriptionSnapshotData({
    required this.chiefComplaint,
    required this.examination,
    required this.diagnosis,
    required this.advice,
    required this.remarks,
    this.followUpDate,
    required this.medicines,
  });

  //===========================================================================
  // From JSON
  //===========================================================================

  factory PrescriptionSnapshotData.fromJson(
    Map<String, dynamic> json,
  ) {
    return PrescriptionSnapshotData(
      chiefComplaint:
          json["chiefComplaint"] ?? "",

      examination:
          json["examination"] ?? "",

      diagnosis:
          json["diagnosis"] ?? "",

      advice:
          json["advice"] ?? "",

      remarks:
          json["remarks"] ?? "",

      followUpDate:
          json["followUpDate"] != null
              ? DateTime.tryParse(
                  json["followUpDate"].toString(),
                )
              : null,

      medicines:
          (json["medicines"] as List? ?? [])
              .whereType<Map>()
              .map(
                (e) => Prescriptiondata.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList(),
    );
  }

  //===========================================================================
  // To JSON
  //===========================================================================

  Map<String, dynamic> toJson() {
    return {
      "chiefComplaint":
          chiefComplaint,

      "examination":
          examination,

      "diagnosis":
          diagnosis,

      "advice":
          advice,

      "remarks":
          remarks,

      "followUpDate":
          followUpDate?.toIso8601String(),

      "medicines":
          medicines
              .map(
                (e) => e.toJson(),
              )
              .toList(),
    };
  }
}


/// ===========================================================================
/// Layout Snapshot
///
/// Stores the printing/layout configuration that was active when the
/// prescription was generated.
///
/// This is part of the immutable prescription snapshot so that the
/// prescription can later be reproduced using the same layout settings.
/// ===========================================================================

class LayoutSnapshot {
  final double headerHeightCm;

  final double footerHeightCm;

  final double leftMarginCm;

  final double rightMarginCm;

  final double topMarginCm;

  final double bottomMarginCm;

  final String pageSize;

  final bool printLetterHead;

  final bool printSignature;

  final bool showPrescriptionQRCode;

  final bool showWatermark;

  final bool showPageNumber;

  final String selectedThemeId;

  const LayoutSnapshot({
    required this.headerHeightCm,
    required this.footerHeightCm,
    required this.leftMarginCm,
    required this.rightMarginCm,
    required this.topMarginCm,
    required this.bottomMarginCm,
    required this.pageSize,
    required this.printLetterHead,
    required this.printSignature,
    required this.showPrescriptionQRCode,
    required this.showWatermark,
    required this.showPageNumber,
    required this.selectedThemeId,
  });

  //===========================================================================
  // From JSON
  //===========================================================================

  factory LayoutSnapshot.fromJson(
    Map<String, dynamic> json,
  ) {
    return LayoutSnapshot(
      headerHeightCm:
          (json["headerHeightCm"] ?? 5.5)
              .toDouble(),

      footerHeightCm:
          (json["footerHeightCm"] ?? 1.5)
              .toDouble(),

      leftMarginCm:
          (json["leftMarginCm"] ?? 1.0)
              .toDouble(),

      rightMarginCm:
          (json["rightMarginCm"] ?? 1.0)
              .toDouble(),

      topMarginCm:
          (json["topMarginCm"] ?? 0.0)
              .toDouble(),

      bottomMarginCm:
          (json["bottomMarginCm"] ?? 0.0)
              .toDouble(),

      pageSize:
          json["pageSize"]?.toString() ?? "A4",

      printLetterHead:
          json["printLetterHead"] ?? true,

      printSignature:
          json["printSignature"] ?? true,

      showPrescriptionQRCode:
          json["showPrescriptionQRCode"] ?? true,

      showWatermark:
          json["showWatermark"] ?? false,

      showPageNumber:
          json["showPageNumber"] ?? false,

      selectedThemeId:
          json["selectedThemeId"]?.toString() ?? "",
    );
  }

  //===========================================================================
  // To JSON
  //===========================================================================

  Map<String, dynamic> toJson() {
    return {
      "headerHeightCm":
          headerHeightCm,

      "footerHeightCm":
          footerHeightCm,

      "leftMarginCm":
          leftMarginCm,

      "rightMarginCm":
          rightMarginCm,

      "topMarginCm":
          topMarginCm,

      "bottomMarginCm":
          bottomMarginCm,

      "pageSize":
          pageSize,

      "printLetterHead":
          printLetterHead,

      "printSignature":
          printSignature,

      "showPrescriptionQRCode":
          showPrescriptionQRCode,

      "showWatermark":
          showWatermark,

      "showPageNumber":
          showPageNumber,

      "selectedThemeId":
          selectedThemeId,
    };
  }
}