import 'dart:convert';
import 'dart:typed_data';

import 'package:docautomations/datamodels/master/patient.dart';
import 'package:docautomations/datamodels/master/patient_doctor.dart';
import 'package:docautomations/viewmodels/patient_view_model.dart';
import 'package:docautomations/viewmodels/prescription_view_model.dart';
import 'package:docautomations/widgets/AddPrescrip.dart';
import 'package:flutter/material.dart';

import 'package:docautomations/common/licenseprovider.dart';
import 'package:docautomations/datamodels/prescriptionData.dart';
import 'package:docautomations/services/license_api_service.dart';
import 'package:docautomations/widgets/Addprescrip.dart';
import 'package:docautomations/widgets/doctorinfo.dart';
import 'package:docautomations/services/logo_service.dart';

class AddPrescriptionController extends ChangeNotifier {

  //---------------------------------------------------------------------------
  // Constructor
  //---------------------------------------------------------------------------

  AddPrescriptionController({
    required this.mode,
    this.patient,
    this.patientDoctor,
  });

  //---------------------------------------------------------------------------
  // Navigation Context
  //---------------------------------------------------------------------------

  final PatientMode mode;

  final Patient? patient;

  final PatientDoctor? patientDoctor;

  final PatientViewModel patientvm = PatientViewModel();

  final PrescriptionViewModel prescriptionvm = PrescriptionViewModel();

  //---------------------------------------------------------------------------
  // UI State
  //---------------------------------------------------------------------------

  bool isLoading = false;

  bool canGenerateNext = false;

  bool printLetterhead = true;

  //---------------------------------------------------------------------------
  // Doctor
  //---------------------------------------------------------------------------

  DoctorInfo? doctorInfo;

  Uint8List? doctorLogo;

    bool get isNewPatient =>
      mode == PatientMode.newPatient;

  bool get isExistingPatient =>
      mode == PatientMode.existingPatient;

  //---------------------------------------------------------------------------
  // Medicines
  //---------------------------------------------------------------------------

  final List<Prescriptiondata> prescriptions = [];


    //---------------------------------------------------------------------------
  // Initialize Controller
  //---------------------------------------------------------------------------

  Future<void> initialize() async {

    isLoading = true;

    notifyListeners();

    try {

      await _loadDoctorInfo();

      switch (mode) {

        case PatientMode.newPatient:

          await _initializeNewPatient();

          break;

        case PatientMode.existingPatient:

          await _loadExistingPatient();

          break;

      }

    }
    catch (e) {

      debugPrint(e.toString());

      rethrow;

    }
    finally {

      isLoading = false;

      notifyListeners();

    }

  }


    //---------------------------------------------------------------------------
  // New Patient
  //---------------------------------------------------------------------------

  Future<void> _initializeNewPatient() async {

    prescriptions.clear();

    canGenerateNext = false;

    //----------------------------------------------------------
    // Patient fields remain empty.
    //
    // PatientInfo widget will display blank controls.
    //----------------------------------------------------------

    notifyListeners();

  }

    //---------------------------------------------------------------------------
  // Existing Patient
  //---------------------------------------------------------------------------

  Future<void> _loadExistingPatient() async {

    if (patientDoctor == null) {

      throw Exception(
        "PatientDoctor is required "
        "for Existing Patient mode.",
      );

    }

    //----------------------------------------------------------
    // Backend returns
    //
    // Patient
    //
    // Latest Prescription
    //
    // already decrypted.
    //----------------------------------------------------------

    final response =
        await LicenseApiService
            .getLatestPrescription(
                patientDoctor!.id,
            );

    //----------------------------------------------------------
    // Patient
    //----------------------------------------------------------

    _populatePatient(
      response.patient,
    );

    //----------------------------------------------------------
    // Prescription
    //----------------------------------------------------------

    _populatePrescription(
      response.latestPrescription,
    );

    notifyListeners();

  }

    //---------------------------------------------------------------------------
  // Populate Patient
  //---------------------------------------------------------------------------

  void _populatePatient(
      Patient patient,
  ) {

    //----------------------------------------------------------
    // Part 2
    //----------------------------------------------------------

  }

  //---------------------------------------------------------------------------
  // Populate Latest Prescription
  //---------------------------------------------------------------------------

  void _populatePrescription(
      GeneratedPrescription prescription,
  ) {

    //----------------------------------------------------------
    // Part 2
    //----------------------------------------------------------

  }

}
