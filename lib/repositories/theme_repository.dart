import 'package:docautomations/common/operation_result.dart';
import 'package:docautomations/datamodels/master/prescription_theme.dart';
import 'package:docautomations/services/theme_api_service.dart';

class ThemeRepository {
  const ThemeRepository({
    required this.apiService,
  });

  final ThemeApiService apiService;

  //===========================================================================
  // Get All Active Themes
  //===========================================================================

  Future<OperationResult> getAllThemes() async {
    try {
      final response = await apiService.getAllThemes();

      if (response["success"] != true) {
        return OperationResult.failure(
          response["message"]?.toString() ??
              "Unable to retrieve prescription themes.",
          data: response["data"],
        );
      }

      if (response["data"] is! List) {
        return OperationResult.failure(
          "Invalid prescription themes response.",
        );
      }

      final themes = (response["data"] as List)
          .whereType<Map>()
          .map(
            (json) => PrescriptionTheme.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .where((theme) => theme.isActive)
          .toList();

      return OperationResult.success(
        response["message"]?.toString() ??
            "Prescription themes retrieved successfully.",
        data: themes,
      );
    } catch (error) {
      return OperationResult.failure(
        "Unable to retrieve prescription themes: $error",
      );
    }
  }
}