import 'package:docautomations/datamodels/master/patient.dart';
import 'package:docautomations/datamodels/master/patient_doctor.dart';
import 'package:docautomations/datamodels/snapshot/prescription_snapshot.dart';

class ExistingPatientVisit {
  final Patient patient;

  final PatientDoctor patientDoctor;

  final PrescriptionSnapshot? latestPrescription;

  const ExistingPatientVisit({
    required this.patient,
    required this.patientDoctor,
    this.latestPrescription,
  });

  factory ExistingPatientVisit.fromJson(
      Map<String, dynamic> json) {
    return ExistingPatientVisit(
      patient: Patient.fromJson(json["patient"]),

      patientDoctor:
          PatientDoctor.fromJson(json["patientDoctor"]),

      latestPrescription:
          json["latestPrescription"] != null
              ? PrescriptionSnapshot.fromJson(
                  json["latestPrescription"],
                )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "patient": patient.toJson(),
      "patientDoctor": patientDoctor.toJson(),
      "latestPrescription":
          latestPrescription?.toJson(),
    };
  }
}