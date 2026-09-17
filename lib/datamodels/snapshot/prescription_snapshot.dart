import 'package:docautomations/datamodels/prescriptionData.dart';

/// ===========================================================================
/// This is the exact object that gets encrypted and stored in
/// GeneratedPrescDetails.encryptedPrescription
/// ===========================================================================
class PrescriptionSnapshot {
  final DoctorSnapshot doctor;

  final PatientSnapshot patient;

  final ClinicSnapshot clinic;

  final PrescriptionSnapshotData prescription;

  const PrescriptionSnapshot({
    required this.doctor,
    required this.patient,
    required this.clinic,
    required this.prescription,
  });

  factory PrescriptionSnapshot.fromJson(
      Map<String, dynamic> json) {
    return PrescriptionSnapshot(
      doctor: DoctorSnapshot.fromJson(json["doctor"] ?? {}),
      patient: PatientSnapshot.fromJson(json["patient"] ?? {}),
      clinic: ClinicSnapshot.fromJson(json["clinic"] ?? {}),
      prescription: PrescriptionSnapshotData.fromJson(
          json["prescription"] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "doctor": doctor.toJson(),
      "patient": patient.toJson(),
      "clinic": clinic.toJson(),
      "prescription": prescription.toJson(),
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

  factory DoctorSnapshot.fromJson(
      Map<String, dynamic> json) {
    return DoctorSnapshot(
      doctorName: json["doctorName"] ?? "",
      qualification: json["qualification"] ?? "",
      specialization: json["specialization"] ?? "",
      registrationNumber:
          json["registrationNumber"] ?? "",
      mobileNumber: json["mobileNumber"] ?? "",
      email: json["email"] ?? "",
    );
  }

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

  factory ClinicSnapshot.fromJson(
      Map<String, dynamic> json) {
    return ClinicSnapshot(
      clinicName: json["clinicName"] ?? "",
      clinicAddress: json["clinicAddress"] ?? "",
      city: json["city"] ?? "",
      state: json["state"] ?? "",
      country: json["country"] ?? "",
      pinCode: json["pinCode"] ?? "",
    );
  }

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

  final DateTime? dateOfBirth;

  final int ageAtVisit;

  final String gender;

  final String mobileNumber;

  final String addressLine1  ;

  final String addressLine2  ;

  final String country;

  final String pinCode; 

  const PatientSnapshot({
    required this.ppid,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    this.dateOfBirth,
    required this.ageAtVisit,
    required this.gender,
    required this.mobileNumber,
    required this.addressLine1,
    required this.addressLine2,
    required this.country,
    required this.pinCode,
  });

  factory PatientSnapshot.fromJson(
      Map<String, dynamic> json) {
    return PatientSnapshot(
      ppid: json["ppid"] ?? "",
      firstName: json["firstName"] ?? "",
      middleName: json["middleName"] ?? "",
      lastName: json["lastName"] ?? "",
      dateOfBirth: json["dateOfBirth"] != null
          ? DateTime.parse(json["dateOfBirth"])
          : null,
      ageAtVisit: json["ageAtVisit"] ?? 0,
      gender: json["gender"] ?? "",
      mobileNumber: json["mobileNumber"] ?? "",
      addressLine1: json["addressLine1"] ?? "",
      addressLine2: json["addressLine2"] ?? "",
      country: json["country"] ?? "",
      pinCode: json["pinCode"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "ppid": ppid,
      "firstName": firstName,
      "middleName": middleName,
      "lastName": lastName,
      "dateOfBirth":
          dateOfBirth?.toIso8601String(),
      "ageAtVisit": ageAtVisit,
      "gender": gender,
      "mobileNumber": mobileNumber,
      "addressLine1": addressLine1, 
      "addressLine2": addressLine2,
      "country": country,
      "pinCode": pinCode,
    };
  }

  String get fullName =>
      "$firstName $middleName $lastName"
          .replaceAll(RegExp(r'\s+'), " ")
          .trim();
}

/// ===========================================================================
/// Prescription Snapshot
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

  factory PrescriptionSnapshotData.fromJson(
      Map<String, dynamic> json) {
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
              ? DateTime.parse(
                  json["followUpDate"])
              : null,
      medicines:
          (json["medicines"] as List? ?? [])
              .map((e) => Prescriptiondata.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "chiefComplaint": chiefComplaint,
      "examination": examination,
      "diagnosis": diagnosis,
      "advice": advice,
      "remarks": remarks,
      "followUpDate":
          followUpDate?.toIso8601String(),
      "medicines":
          medicines.map((e) => e.toJson()).toList(),
    };
  }

  
}

class LayoutSnapshot {
  

  final double headerHeightCm ;

  final double footerHeightCm;

  final double leftMarginCm;

  final double rightMarginCm;

  final double topMarginCm;

  final double bottomMarginCm;

  final String pageSize; 

  final bool printLetterHead;

  final bool printSignature;

  final bool printQRCode;

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
    required this.printQRCode,
    required this.selectedThemeId,
  });

  factory LayoutSnapshot.fromJson(
      Map<String, dynamic> json) {
    return LayoutSnapshot(
      headerHeightCm: (json["headerHeightCm"] ?? 4.0).toDouble(),
      footerHeightCm: (json["footerHeightCm"] ?? 2.0).toDouble(),
      leftMarginCm: (json["leftMarginCm"] ?? 1.0).toDouble(),
      rightMarginCm: (json["rightMarginCm"] ?? 1.0).toDouble(),
      topMarginCm: (json["topMarginCm"] ?? 1.0).toDouble(),
      bottomMarginCm: (json["bottomMarginCm"] ?? 1.0).toDouble(),
      pageSize: json["pageSize"] ?? "A4",            
      printLetterHead: json["printLetterHead"] ?? true,
      printSignature: json["printSignature"] ?? true,
      printQRCode: json["printQRCode"] ?? true,
      selectedThemeId: json["selectedThemeId"] ?? "",
    );
  }

 Map<String, dynamic> toJson() {
    return {
      "headerHeightCm": headerHeightCm,
      "footerHeightCm": footerHeightCm,      
      "leftMarginCm": leftMarginCm,
      "rightMarginCm": rightMarginCm,
      "topMarginCm": topMarginCm,
      "bottomMarginCm": bottomMarginCm,
      "pageSize": pageSize,
      "printLetterHead": printLetterHead,
      "printSignature": printSignature,
      "printQRCode": printQRCode,
      "selectedThemeId": selectedThemeId,
    };
  }

  
}
