import 'package:docautomations/datamodels/master/patient.dart';
import 'package:docautomations/datamodels/master/patient_doctor.dart';

class PatientSearchResult {

  final Patient patient;

  final PatientDoctor? patientDoctor;

  final Map<String, dynamic>? prescription;


  const PatientSearchResult({

    required this.patient,

    this.patientDoctor,

    this.prescription,

  });


  factory PatientSearchResult.fromJson(
    Map<String, dynamic> json,
  ) {

    final patientJson =
        Map<String, dynamic>.from(
      json["patient"] as Map,
    );


    PatientDoctor? patientDoctor;


    if (json["patientDoctor"] != null) {

      patientDoctor =
          PatientDoctor.fromJson(
        Map<String, dynamic>.from(
          json["patientDoctor"] as Map,
        ),
      );

    }


    Map<String, dynamic>? prescription;


    if (json["prescription"] != null) {

      prescription =
          Map<String, dynamic>.from(
        json["prescription"] as Map,
      );

    }


    return PatientSearchResult(

      patient:
          Patient.fromJson(patientJson),

      patientDoctor:
          patientDoctor,

      prescription:
          prescription,

    );

  }

}