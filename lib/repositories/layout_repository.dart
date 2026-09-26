import 'package:docautomations/datamodels/master/prescription_layout.dart';
import 'package:docautomations/common/operation_result.dart';
import 'package:docautomations/services/layout_api_service.dart';


class LayoutRepository {

  //===========================================================================
  // Constructor
  //===========================================================================

  const LayoutRepository({
    required this.apiService,
  });


  //===========================================================================
  // Dependencies
  //===========================================================================

  final LayoutApiService apiService;


  //===========================================================================
  // Get Doctor Layout
  //===========================================================================

  Future<OperationResult> getDoctorLayout() async {

    try {

      final response =
          await apiService.getDoctorLayout();


      if (response["success"] != true) {

        return OperationResult.failure(

          response["message"]?.toString() ??
              "Unable to retrieve prescription layout.",

          data:
              response["data"],

        );
      }


      if (response["data"] is! Map) {

        return OperationResult.failure(
          "Invalid prescription layout response.",
        );
      }


      final layout =
          PrescriptionLayout.fromJson(

        Map<String, dynamic>.from(
          response["data"] as Map,
        ),

      );


      return OperationResult.success(

        response["message"]?.toString() ??
            "Prescription layout retrieved successfully.",

        data:
            layout,

      );

    } catch (error) {

      return OperationResult.failure(

        "Unable to retrieve prescription layout: $error",

      );

    }

  }


  //===========================================================================
  // Update Doctor Layout
  //===========================================================================

  Future<OperationResult> updateDoctorLayout(
    Map<String, dynamic> request,
  ) async {

    try {

      final response =
          await apiService.updateDoctorLayout(
        request,
      );


      if (response["success"] != true) {

        return OperationResult.failure(

          response["message"]?.toString() ??
              "Unable to update prescription layout.",

          data:
              response["data"],

        );
      }


      if (response["data"] is! Map) {

        return OperationResult.failure(
          "Invalid prescription layout response.",
        );
      }


      final layout =
          PrescriptionLayout.fromJson(

        Map<String, dynamic>.from(
          response["data"] as Map,
        ),

      );


      return OperationResult.success(

        response["message"]?.toString() ??
            "Prescription layout updated successfully.",

        data:
            layout,

      );

    } catch (error) {

      return OperationResult.failure(

        "Unable to update prescription layout: $error",

      );

    }

  }


  //===========================================================================
  // Reset Doctor Layout
  //===========================================================================

  Future<OperationResult> resetDoctorLayout() async {

    try {

      final response =
          await apiService.resetDoctorLayout();


      if (response["success"] != true) {

        return OperationResult.failure(

          response["message"]?.toString() ??
              "Unable to reset prescription layout.",

          data:
              response["data"],

        );
      }


      if (response["data"] is! Map) {

        return OperationResult.failure(
          "Invalid prescription layout response.",
        );

      }


      final layout =
          PrescriptionLayout.fromJson(

        Map<String, dynamic>.from(
          response["data"] as Map,
        ),

      );


      return OperationResult.success(

        response["message"]?.toString() ??
            "Prescription layout reset successfully.",

        data:
            layout,

      );

    } catch (error) {

      return OperationResult.failure(

        "Unable to reset prescription layout: $error",

      );

    }

  }

}