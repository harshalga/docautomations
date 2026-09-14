import 'package:docautomations/common/operation_result.dart';
import 'package:docautomations/datamodels/master/patient.dart';
import 'package:docautomations/datamodels/master/patient_doctor.dart';
import 'package:docautomations/services/patient_api_service.dart';

class PatientRepository {
  final PatientApiService apiService;

  const PatientRepository({
    required this.apiService,
  });

  //-------------------------------------------------------------------------
  // FIND OR CREATE PATIENT
  //-------------------------------------------------------------------------
  //
  // The backend performs two operations:
  //
  // 1. Find/create the global Patient record.
  // 2. Find/create the PatientDoctor relationship for the
  //    currently authenticated doctor.
  //
  // The returned PatientDoctor ID is required later by the
  // prescription workflow as patientDoctorId.
  //
  //-------------------------------------------------------------------------

  Future<OperationResult> findOrCreatePatient(
    Patient patient,
  ) async {
    try {
      final response = await apiService.findOrCreatePatient(
        patient.toJson(),
      );

      if (response["success"] != true) {
        return OperationResult.failure(
          response["message"]?.toString() ??
              "Unable to create or retrieve patient.",
          data: response["data"],
        );
      }

      final data = response["data"];

      if (data == null) {
        return OperationResult.failure(
          "Patient relationship was not returned by the server.",
        );
      }

      return OperationResult.success(
        response["message"]?.toString() ??
            "Patient retrieved successfully.",
        data: _parsePatientDoctor(data),
      );
    } catch (error) {
      return OperationResult.failure(
        "Unable to create or retrieve patient: $error",
      );
    }
  }

  //-------------------------------------------------------------------------
  // SEARCH PATIENTS
  //-------------------------------------------------------------------------
  //
  // The backend search is doctor-scoped through PatientDoctor.
  //
  // Depending on the backend response shape, the data may contain
  // PatientDoctor records with a populated Patient.
  //
  //-------------------------------------------------------------------------

  Future<OperationResult> searchPatients({
    required String searchText,
  }) async {
    try {
      final response = await apiService.searchPatients(
        searchText: searchText,
      );

      if (response["success"] != true) {
        return OperationResult.failure(
          response["message"]?.toString() ??
              "Unable to search patients.",
          data: response["data"],
        );
      }

      final data = response["data"];

      if (data == null) {
        return OperationResult.success(
          response["message"]?.toString() ??
              "Patients retrieved successfully.",
          data: <PatientDoctor>[],
        );
      }

      final patients = _parsePatientDoctorList(data);

      return OperationResult.success(
        response["message"]?.toString() ??
            "Patients retrieved successfully.",
        data: patients,
      );
    } catch (error) {
      return OperationResult.failure(
        "Unable to search patients: $error",
      );
    }
  }

  //-------------------------------------------------------------------------
  // GET PATIENT
  //-------------------------------------------------------------------------

  Future<OperationResult> getPatient(
    String patientId,
  ) async {
    try {
      final response =
          await apiService.getPatient(patientId);

      if (response["success"] != true) {
        return OperationResult.failure(
          response["message"]?.toString() ??
              "Unable to retrieve patient.",
          data: response["data"],
        );
      }

      final data = response["data"];

      if (data == null) {
        return OperationResult.failure(
          "Patient data was not returned by the server.",
        );
      }

      return OperationResult.success(
        response["message"]?.toString() ??
            "Patient retrieved successfully.",
        data: Patient.fromJson(
          Map<String, dynamic>.from(data),
        ),
      );
    } catch (error) {
      return OperationResult.failure(
        "Unable to retrieve patient: $error",
      );
    }
  }

  //-------------------------------------------------------------------------
  // UPDATE PATIENT
  //-------------------------------------------------------------------------

  Future<OperationResult> updatePatient(
    String patientId,
    Patient patient,
  ) async {
    try {
      final response =
          await apiService.updatePatient(
        patientId,
        patient.toJson(),
      );

      if (response["success"] != true) {
        return OperationResult.failure(
          response["message"]?.toString() ??
              "Unable to update patient.",
          data: response["data"],
        );
      }

      final data = response["data"];

      if (data == null) {
        return OperationResult.success(
          response["message"]?.toString() ??
              "Patient updated successfully.",
        );
      }

      return OperationResult.success(
        response["message"]?.toString() ??
            "Patient updated successfully.",
        data: Patient.fromJson(
          Map<String, dynamic>.from(data),
        ),
      );
    } catch (error) {
      return OperationResult.failure(
        "Unable to update patient: $error",
      );
    }
  }

  //-------------------------------------------------------------------------
  // DELETE PATIENT
  //-------------------------------------------------------------------------

  Future<OperationResult> deletePatient(
    String patientId,
  ) async {
    try {
      final response =
          await apiService.deletePatient(patientId);

      if (response["success"] != true) {
        return OperationResult.failure(
          response["message"]?.toString() ??
              "Unable to delete patient.",
          data: response["data"],
        );
      }

      return OperationResult.success(
        response["message"]?.toString() ??
            "Patient deleted successfully.",
        data: response["data"],
      );
    } catch (error) {
      return OperationResult.failure(
        "Unable to delete patient: $error",
      );
    }
  }

  //-------------------------------------------------------------------------
  // PARSE PATIENT DOCTOR
  //-------------------------------------------------------------------------
  //
  // PatientDoctor may contain a populated patientId:
  //
  // {
  //   "_id": "...",
  //   "patientId": {
  //     "_id": "...",
  //     "firstName": "...",
  //     ...
  //   },
  //   "doctorId": "...",
  //   ...
  // }
  //
  // The PatientDoctor model currently stores patientId as String,
  // so a populated patient is not directly represented inside it.
  //
  // This method therefore expects the relationship to contain a
  // normal patientId string. If the backend returns a populated
  // patient, that response shape should be handled by a dedicated
  // composite model later.
  //
  //-------------------------------------------------------------------------

  PatientDoctor _parsePatientDoctor(
    dynamic data,
  ) {
    return PatientDoctor.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  //-------------------------------------------------------------------------
  // PARSE PATIENT DOCTOR LIST
  //-------------------------------------------------------------------------

  List<PatientDoctor> _parsePatientDoctorList(
    dynamic data,
  ) {
    if (data is! List) {
      return <PatientDoctor>[];
    }

    return data
        .map(
          (item) => PatientDoctor.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }
}

