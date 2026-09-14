import 'package:docautomations/common/operation_result.dart';
import 'package:docautomations/services/prescription_api_service.dart';

class PrescriptionRepository {
  final PrescriptionApiService apiService;

  const PrescriptionRepository({
    required this.apiService,
  });

  //-------------------------------------------------------------------------
  // CREATE PRESCRIPTION
  //-------------------------------------------------------------------------

  Future<OperationResult> createPrescription(
    Map<String, dynamic> request,
  ) async {
    try {
      final response =
          await apiService.createPrescription(request);

      if (response["success"] != true) {
        return OperationResult.failure(
          response["message"]?.toString() ??
              "Unable to create prescription.",
          data: response["data"],
        );
      }

      return OperationResult.success(
        response["message"]?.toString() ??
            "Prescription created successfully.",
        data: response["data"],
      );
    } catch (error) {
      return OperationResult.failure(
        "Unable to create prescription: $error",
      );
    }
  }

  //-------------------------------------------------------------------------
  // REVISE PRESCRIPTION
  //-------------------------------------------------------------------------

  Future<OperationResult> revisePrescription(
    String prescriptionId,
    Map<String, dynamic> request,
  ) async {
    try {
      final response =
          await apiService.revisePrescription(
        prescriptionId,
        request,
      );

      if (response["success"] != true) {
        return OperationResult.failure(
          response["message"]?.toString() ??
              "Unable to revise prescription.",
          data: response["data"],
        );
      }

      return OperationResult.success(
        response["message"]?.toString() ??
            "Prescription revised successfully.",
        data: response["data"],
      );
    } catch (error) {
      return OperationResult.failure(
        "Unable to revise prescription: $error",
      );
    }
  }

  //-------------------------------------------------------------------------
  // GET LATEST PRESCRIPTION
  //-------------------------------------------------------------------------

  Future<OperationResult> getLatestPrescription(
    String patientDoctorId,
  ) async {
    try {
      final response =
          await apiService.getLatestPrescription(
        patientDoctorId,
      );

      if (response["success"] != true) {
        return OperationResult.failure(
          response["message"]?.toString() ??
              "Unable to retrieve latest prescription.",
          data: response["data"],
        );
      }

      return OperationResult.success(
        response["message"]?.toString() ??
            "Latest prescription retrieved successfully.",
        data: response["data"],
      );
    } catch (error) {
      return OperationResult.failure(
        "Unable to retrieve latest prescription: $error",
      );
    }
  }

  //-------------------------------------------------------------------------
  // GET PRESCRIPTION HISTORY
  //-------------------------------------------------------------------------

  Future<OperationResult> getPrescriptionHistory(
    String patientDoctorId,
  ) async {
    try {
      final response =
          await apiService.getPrescriptionHistory(
        patientDoctorId,
      );

      if (response["success"] != true) {
        return OperationResult.failure(
          response["message"]?.toString() ??
              "Unable to retrieve prescription history.",
          data: response["data"],
        );
      }

      return OperationResult.success(
        response["message"]?.toString() ??
            "Prescription history retrieved successfully.",
        data: response["data"],
      );
    } catch (error) {
      return OperationResult.failure(
        "Unable to retrieve prescription history: $error",
      );
    }
  }

  //-------------------------------------------------------------------------
  // GET PRESCRIPTION
  //-------------------------------------------------------------------------

  Future<OperationResult> getPrescription(
    String prescriptionId,
  ) async {
    try {
      final response =
          await apiService.getPrescription(
        prescriptionId,
      );

      if (response["success"] != true) {
        return OperationResult.failure(
          response["message"]?.toString() ??
              "Unable to retrieve prescription.",
          data: response["data"],
        );
      }

      return OperationResult.success(
        response["message"]?.toString() ??
            "Prescription retrieved successfully.",
        data: response["data"],
      );
    } catch (error) {
      return OperationResult.failure(
        "Unable to retrieve prescription: $error",
      );
    }
  }

  //-------------------------------------------------------------------------
  // CANCEL PRESCRIPTION
  //-------------------------------------------------------------------------

  Future<OperationResult> cancelPrescription(
    String prescriptionId,
  ) async {
    try {
      final response =
          await apiService.cancelPrescription(
        prescriptionId,
      );

      if (response["success"] != true) {
        return OperationResult.failure(
          response["message"]?.toString() ??
              "Unable to cancel prescription.",
          data: response["data"],
        );
      }

      return OperationResult.success(
        response["message"]?.toString() ??
            "Prescription cancelled successfully.",
        data: response["data"],
      );
    } catch (error) {
      return OperationResult.failure(
        "Unable to cancel prescription: $error",
      );
    }
  }
}
