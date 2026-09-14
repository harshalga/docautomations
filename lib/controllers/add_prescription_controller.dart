import 'package:flutter/material.dart';
import 'package:docautomations/datamodels/snapshot/prescription_snapshot.dart';
import 'package:docautomations/datamodels/master/patient.dart';
import 'package:docautomations/datamodels/master/patient_doctor.dart';
import 'package:docautomations/datamodels/prescriptionData.dart';

import 'package:docautomations/repositories/prescription_repository.dart';

import 'package:docautomations/widgets/AddPrescrip.dart';


class AddPrescriptionController
    extends ChangeNotifier {

  //===========================================================================
  // Constructor
  //===========================================================================

  AddPrescriptionController({
    required this.mode,
    this.patient,
    this.patientDoctor,
    required this.prescriptionRepository,
  });


  //===========================================================================
  // Patient / Navigation Context
  //===========================================================================

  final PatientMode mode;

  final Patient? patient;

  final PatientDoctor? patientDoctor;


  //===========================================================================
  // Repository
  //===========================================================================

  final PrescriptionRepository prescriptionRepository;


  //===========================================================================
  // UI State
  //===========================================================================

  bool isLoading = false;

  bool canGenerateNext = false;

  bool printLetterhead = true;


  //===========================================================================
  // Patient State
  //===========================================================================

  Patient? _currentPatient;

  Patient? get currentPatient =>
      _currentPatient;


  //===========================================================================
  // Prescription State
  //===========================================================================

  final List<Prescriptiondata> prescriptions = [];


  //===========================================================================
  // Convenience Getters
  //===========================================================================

  bool get isNewPatient =>
      mode == PatientMode.newPatient;


  bool get isExistingPatient =>
      mode == PatientMode.existingPatient;


  //===========================================================================
  // Initialize Controller
  //===========================================================================

  Future<void> initialize() async {

    isLoading = true;

    notifyListeners();

    try {

      switch (mode) {

        case PatientMode.newPatient:

          await _initializeNewPatient();

          break;


        case PatientMode.existingPatient:

          await _loadExistingPatient();

          break;

      }

    }
    catch (error) {

      debugPrint(
        "AddPrescriptionController.initialize: $error",
      );

      rethrow;

    }
    finally {

      isLoading = false;

      notifyListeners();

    }

  }


  //===========================================================================
  // Initialize New Patient
  //===========================================================================

  Future<void> _initializeNewPatient() async {

    prescriptions.clear();

    canGenerateNext = false;

    _currentPatient = patient;

    notifyListeners();

  }


  
//===========================================================================
// Load Existing Patient
//===========================================================================
//
// Existing patient flow:
//
//     PatientDoctor
//          |
//          v
// PrescriptionRepository
//          |
//          v
// Latest Prescription
//          |
//          v
// PrescriptionSnapshot
//          |
//          v
// Prescriptiondata[]
//
//===========================================================================

Future<void> _loadExistingPatient() async {

  //-------------------------------------------------------------------------
  // Validate PatientDoctor
  //-------------------------------------------------------------------------

  if (patientDoctor == null) {

    throw Exception(
      "PatientDoctor is required "
      "for Existing Patient mode.",
    );

  }


  //-------------------------------------------------------------------------
  // Set Current Patient
  //-------------------------------------------------------------------------

  _currentPatient = patient;


  //-------------------------------------------------------------------------
  // Clear Existing Prescription State
  //-------------------------------------------------------------------------

  prescriptions.clear();

  canGenerateNext = false;

  notifyListeners();


  //-------------------------------------------------------------------------
  // Retrieve Latest Prescription
  //-------------------------------------------------------------------------

  final result =
      await prescriptionRepository.getLatestPrescription(
    patientDoctor!.id,
  );


  //-------------------------------------------------------------------------
  // No Latest Prescription
  //-------------------------------------------------------------------------
  //
  // This is not necessarily an error.
  //
  // An existing patient may not have a previous prescription.
  //
  //-------------------------------------------------------------------------

  if (!result.success) {

    debugPrint(
      "Latest prescription not available: "
      "${result.message}",
    );

    return;

  }


  //-------------------------------------------------------------------------
  // Validate Response
  //-------------------------------------------------------------------------

  if (result.data == null) {

    return;

  }


  if (result.data is! Map<String, dynamic>) {

    debugPrint(
      "Unexpected latest prescription response format.",
    );

    return;

  }


  //-------------------------------------------------------------------------
  // Convert Backend Snapshot
  //-------------------------------------------------------------------------
  //
  // PrescriptionService.getLatestPrescription() decrypts the
  // GeneratedPrescDetails encryption payload on the backend and returns
  // the decrypted prescription snapshot.
  //
  // Therefore result.data should represent:
  //
  // {
  //   "doctor": {...},
  //   "patient": {...},
  //   "clinic": {...},
  //   "prescription": {
  //      ...
  //      "medicines": [...]
  //   }
  // }
  //
  //-------------------------------------------------------------------------

  final snapshot =
      PrescriptionSnapshot.fromJson(
    Map<String, dynamic>.from(
      result.data,
    ),
  );


  //-------------------------------------------------------------------------
  // Restore Medicines
  //-------------------------------------------------------------------------

  _populatePrescription(
    snapshot.prescription.medicines,
  );


  //-------------------------------------------------------------------------
  // Existing Patient Is Ready
  //-------------------------------------------------------------------------

  canGenerateNext =
      prescriptions.isNotEmpty;

  notifyListeners();

}




  //===========================================================================
  // Populate Patient
  //===========================================================================

  void _populatePatient(
    Patient value,
  ) {

    _currentPatient = value;

    notifyListeners();

  }


  //===========================================================================
  // Populate Prescription
  //===========================================================================

  void _populatePrescription(
    List<Prescriptiondata> values,
  ) {

    prescriptions
      ..clear()
      ..addAll(values);

    notifyListeners();

  }


  //===========================================================================
  // Reset Prescription
  //===========================================================================

  void resetPrescription() {

    prescriptions.clear();

    canGenerateNext = false;

    notifyListeners();

  }


  //===========================================================================
  // Dispose
  //===========================================================================

  @override
  void dispose() {

    super.dispose();

  }

}

