
import 'package:docautomations/datamodels/prescriptionData.dart';

class PrescriptionViewModel  {
  //---------------------------------------------------------------------------
  // Identity
  //---------------------------------------------------------------------------

  String prescriptionId = "";

  String parentPrescriptionId = "";

  //---------------------------------------------------------------------------
  // Clinical Details
  //---------------------------------------------------------------------------

  String chiefComplaint = "";

  String examination = "";

  String diagnosis = "";

  String advice = "";

  String remarks = "";

  //---------------------------------------------------------------------------
  // Follow-up
  //---------------------------------------------------------------------------

  DateTime? followUpDate;

  //---------------------------------------------------------------------------
  // Medicines
  //---------------------------------------------------------------------------

  final List<Prescriptiondata> medicines = [];

  //---------------------------------------------------------------------------
  // Prescription Status
  //---------------------------------------------------------------------------

  bool printLetterHead = true;

  bool isRevision = false;

  bool isDirty = false;


  //---------------------------------------------------------------------------
  // Constructors
  //---------------------------------------------------------------------------

  PrescriptionViewModel();

  factory PrescriptionViewModel.fromJson(
      Map<String, dynamic> json) {
    final vm = PrescriptionViewModel();

    vm.populateFromJson(json);

    return vm;
  }

  //  //---------------------------------------------------------------------------
  // // Populate
  // //---------------------------------------------------------------------------

  // void populate(Map<String, dynamic> json) {
  //   prescriptionId =
  //       json["_id"]?.toString() ?? "";

  //   parentPrescriptionId =
  //       json["parentPrescriptionId"]?.toString() ?? "";

  //   chiefComplaint =
  //       json["chiefComplaint"] ?? "";

  //   examination =
  //       json["examination"] ?? "";

  //   diagnosis =
  //       json["diagnosis"] ?? "";

  //   advice =
  //       json["advice"] ?? "";

  //   remarks =
  //       json["remarks"] ?? "";

  //   printLetterHead =
  //       json["printLetterHead"] ?? true;

  //   if (json["followUpDate"] != null) {
  //     followUpDate = DateTime.parse(
  //       json["followUpDate"],
  //     );
  //   }

  //   medicines.clear();

  //   if (json["medicines"] != null) {
  //     for (final medicine
  //         in json["medicines"]) {
  //       medicines.add(
  //         Prescriptiondata.fromJson(
  //           medicine,
  //         ),
  //       );
  //     }
  //   }

  //   isRevision =
  //       parentPrescriptionId.isNotEmpty;
  // }

  //---------------------------------------------------------------------------
  // Clear
  //---------------------------------------------------------------------------

  // void clear() {
  //   prescriptionId = "";

  //   parentPrescriptionId = "";

  //   chiefComplaint = "";

  //   examination = "";

  //   diagnosis = "";

  //   advice = "";

  //   remarks = "";

  //   followUpDate = null;

  //   medicines.clear();

  //   printLetterHead = true;

  //   isRevision = false;
  // }


  //---------------------------------------------------------------------------
  //Medicine Helpers
  //Add Medicine
  //---------------------------------------------------------------------------

  void addMedicine(Prescriptiondata medicine) {
    medicines.add(medicine);

    isDirty = true;

  }

  //---------------------------------------------------------------------------
  // Update Medicine
  //---------------------------------------------------------------------------

  void updateMedicine(
    int index,
    Prescriptiondata medicine,
  ) {
    if (index < 0 || index >= medicines.length) return;

    medicines[index] = medicine;

    isDirty = true;


  }

  //---------------------------------------------------------------------------
  // Delete Medicine
  //---------------------------------------------------------------------------

  void deleteMedicine(int index) {
    if (index < 0 || index >= medicines.length) return;

    medicines.removeAt(index);

    isDirty = true;


  }

  //---------------------------------------------------------------------------
  // Clear Medicines
  //---------------------------------------------------------------------------

  void clearMedicines() {
    medicines.clear();

    isDirty = true;


  }

  //---------------------------------------------------------------------------
  // Populate
  //---------------------------------------------------------------------------

  void populateFromJson(
    Map<String, dynamic> json,
  ) {
    prescriptionId =
        json["_id"] ?? "";

    parentPrescriptionId =
        json["parentPrescriptionId"] ?? "";

    chiefComplaint =
        json["chiefComplaint"] ?? "";

    examination =
        json["examination"] ?? "";

    diagnosis =
        json["diagnosis"] ?? "";

    advice =
        json["advice"] ?? "";

    remarks =
        json["remarks"] ?? "";

    if (json["followUpDate"] != null) {
      followUpDate =
          DateTime.parse(json["followUpDate"]);
    }

    medicines.clear();

    if (json["medicines"] != null) {
      for (final medicine
          in json["medicines"]) {
        medicines.add(
          Prescriptiondata.fromJson(
            medicine,
          ),
        );
      }
    }

    printLetterHead =
        json["printLetterHead"] ?? true;

    isRevision =
        parentPrescriptionId.isNotEmpty;

    isDirty = false;

    
  }

  //---------------------------------------------------------------------------
  // Reset
  //---------------------------------------------------------------------------

  void clear() {
    prescriptionId = "";

    parentPrescriptionId = "";

    chiefComplaint = "";

    examination = "";

    diagnosis = "";

    advice = "";

    remarks = "";

    followUpDate = null;

    medicines.clear();

    isRevision = false;

    isDirty = false;

    
  }

  //---------------------------------------------------------------------------
  // JSON
  //---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      "prescriptionId":
          prescriptionId,

      "parentPrescriptionId":
          parentPrescriptionId,

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
          followUpDate
              ?.toIso8601String(),

      "printLetterHead":
          printLetterHead,

      "medicines":
          medicines
              .map(
                (e) => e.toJson(),
              )
              .toList(),
    };
  }

  //---------------------------------------------------------------------------
  // Helpers
  //---------------------------------------------------------------------------

  bool get hasMedicines =>
      medicines.isNotEmpty;

  bool get hasDiagnosis =>
      diagnosis.trim().isNotEmpty;

  bool get hasChiefComplaint =>
      chiefComplaint.trim().isNotEmpty;

  bool get canGeneratePrescription =>
      medicines.isNotEmpty;

  int get medicineCount =>
      medicines.length;
}