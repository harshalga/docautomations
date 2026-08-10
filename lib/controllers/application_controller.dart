import 'package:flutter/material.dart';

import 'package:docautomations/application/application_bootstrapper.dart';
import 'package:docautomations/datamodels/master/master_data.dart';

class ApplicationController extends ChangeNotifier {
  //---------------------------------------------------------------------------
  // Dependencies
  //---------------------------------------------------------------------------

  final ApplicationBootstrapper initializer;

  //---------------------------------------------------------------------------
  // Constructor
  //---------------------------------------------------------------------------

  ApplicationController({
    required this.initializer,
  });

  //---------------------------------------------------------------------------
  // State
  //---------------------------------------------------------------------------

  MasterData? _masterData;

  bool _initialized = false;

  bool _loading = false;

  String? _errorMessage;

  //---------------------------------------------------------------------------
  // Getters
  //---------------------------------------------------------------------------

  MasterData get masterData {
    if (_masterData == null) {
      throw StateError(
        "ApplicationController has not been initialized.",
      );
    }

    return _masterData!;
  }

  bool get initialized => _initialized;

  bool get loading => _loading;

  String? get errorMessage => _errorMessage;

  //---------------------------------------------------------------------------
  // Initialize
  //---------------------------------------------------------------------------

  Future<void> initialize({
    bool forceRefresh = false,
  }) async {
    if (_initialized && !forceRefresh) {
      return;
    }

    _loading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _masterData =
          await initializer.initialize(
        forceRefresh: forceRefresh,
      );

      _initialized = true;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _loading = false;

      notifyListeners();
    }
  }

  //---------------------------------------------------------------------------
  // Refresh
  //---------------------------------------------------------------------------

  Future<void> refresh() async {
    await initialize(
      forceRefresh: true,
    );
  }

  //---------------------------------------------------------------------------
  // Clear
  //---------------------------------------------------------------------------

  Future<void> clear() async {
    await initializer.clearCache();

    _masterData = null;

    _initialized = false;

    _loading = false;

    _errorMessage = null;

    notifyListeners();
  }
}