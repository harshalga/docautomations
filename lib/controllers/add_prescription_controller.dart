import 'package:docautomations/viewmodels/prescription_view_model.dart';
import 'package:flutter/material.dart';

import 'package:docautomations/datamodels/master/patient.dart';
import 'package:docautomations/datamodels/master/patient_doctor.dart';
import 'package:docautomations/datamodels/prescriptionData.dart';
import 'package:docautomations/datamodels/snapshot/prescription_snapshot.dart';

import 'package:docautomations/repositories/prescription_repository.dart';

import 'package:docautomations/datamodels/master/patient_mode.dart';


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
  //
  // PrescriptionViewModel is the single source of truth for prescription
  // editing state.
  //
  // Do NOT maintain another List<Prescriptiondata> here.
  //
  //===========================================================================

  final PrescriptionViewModel prescription =
      PrescriptionViewModel();


  //===========================================================================
  // Compatibility Getter
  //===========================================================================
  //
  // Existing prescription widgets may already use:
  //
  //     controller.prescriptions
  //
  // Keep this getter so those widgets don't need to be changed immediately.
  //
  // The actual list is owned by PrescriptionViewModel.
  //
  //===========================================================================

  List<Prescriptiondata> get prescriptions =>
      prescription.medicines;


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

    prescription.clear();

    printLetterhead = true;

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
  // PrescriptionSnapshotData
  //          |
  //          v
  // PrescriptionViewModel
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

    prescription.clear();

    printLetterhead = true;

    canGenerateNext = false;

    notifyListeners();


    //-------------------------------------------------------------------------
    // Retrieve Latest Prescription
    //-------------------------------------------------------------------------

    final result =
        await prescriptionRepository
            .getLatestPrescription(
      patientDoctor!.id,
    );


    //-------------------------------------------------------------------------
    // No Prescription Available
    //-------------------------------------------------------------------------
    //
    // An existing patient does not necessarily have a previous prescription.
    //
    // This is a valid state and should leave the prescription editor empty.
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


    if (result.data is! Map) {

      debugPrint(
        "Unexpected latest prescription response format.",
      );

      return;

    }


    //-------------------------------------------------------------------------
    // Convert Response Into PrescriptionSnapshot
    //-------------------------------------------------------------------------

    final snapshot =
        PrescriptionSnapshot.fromJson(
      Map<String, dynamic>.from(
        result.data as Map,
      ),
    );


    //-------------------------------------------------------------------------
    // Populate Prescription View Model
    //-------------------------------------------------------------------------
    //
    // PrescriptionSnapshotData and PrescriptionViewModel intentionally
    // remain separate:
    //
    // PrescriptionSnapshotData
    //     = immutable persisted/printed snapshot
    //
    // PrescriptionViewModel
    //     = editable screen state
    //
    //-------------------------------------------------------------------------

    final snapshotPrescription =
        snapshot.prescription;


    prescription
      ..chiefComplaint =
          snapshotPrescription.chiefComplaint
      ..examination =
          snapshotPrescription.examination
      ..diagnosis =
          snapshotPrescription.diagnosis
      ..advice =
          snapshotPrescription.advice
      ..remarks =
          snapshotPrescription.remarks
      ..followUpDate =
          snapshotPrescription.followUpDate
      ..medicines
          .addAll(snapshotPrescription.medicines)
      ..isDirty = false;


    //-------------------------------------------------------------------------
    // Print Letterhead
    //-------------------------------------------------------------------------
    //
    // The current PrescriptionSnapshotData does not contain
    // printLetterHead.
    //
    // Therefore retain the controller's default until LayoutSnapshot is
    // incorporated into the persisted prescription snapshot.
    //
    //-------------------------------------------------------------------------

    printLetterhead = true;

    prescription.printLetterHead =
        printLetterhead;


    //-------------------------------------------------------------------------
    // Prescription Is Ready
    //-------------------------------------------------------------------------

    canGenerateNext =
        prescription.canGeneratePrescription;

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

    prescription
      ..medicines
          .clear()
      ..medicines
          .addAll(values)
      ..isDirty = false;

    canGenerateNext =
        prescription.canGeneratePrescription;

    notifyListeners();

  }


  //===========================================================================
  // Add Medicine
  //===========================================================================

  void addMedicine(
    Prescriptiondata medicine,
  ) {

    prescription.addMedicine(
      medicine,
    );

    canGenerateNext =
        prescription.canGeneratePrescription;

    notifyListeners();

  }


  //===========================================================================
  // Update Medicine
  //===========================================================================

  void updateMedicine(
    int index,
    Prescriptiondata medicine,
  ) {

    prescription.updateMedicine(
      index,
      medicine,
    );

    canGenerateNext =
        prescription.canGeneratePrescription;

    notifyListeners();

  }


  //===========================================================================
  // Delete Medicine
  //===========================================================================

  void deleteMedicine(
    int index,
  ) {

    prescription.deleteMedicine(
      index,
    );

    canGenerateNext =
        prescription.canGeneratePrescription;

    notifyListeners();

  }


  //===========================================================================
  // Reset Prescription
  //===========================================================================

  void resetPrescription() {

    prescription.clear();

    printLetterhead = true;

    canGenerateNext = false;

    notifyListeners();

  }


  //===========================================================================
  // Dispose
  //===========================================================================


}

