import 'package:docautomations/services/auth_service.dart';
import 'package:docautomations/services/license_api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LicenseProvider with ChangeNotifier {
  // ============================================================
  // Internal State Variables (private)
  // ============================================================

  bool _isLoading = false;
  bool _statusLoaded = false;
  bool _isFetching = false;

  // Trial state
  bool _isTrialActive = false;
  int _prescriptionCount = 0;
  DateTime? _trialEndDate;

  // Subscription state
  bool _isSubscribed = false;
  DateTime? _subscriptionExpiry;
  String? _productId;

  // ============================================================
  // PUBLIC GETTERS
  // ============================================================

  bool get isLoading => _isLoading;
  bool get isTrialActive => _isTrialActive;
  int get prescriptionCount => _prescriptionCount;
  DateTime? get trialEndDate => _trialEndDate;

  bool get isSubscribed => _isSubscribed;
  DateTime? get subscriptionExpiry => _subscriptionExpiry;
  String? get productId => _productId;

  /// Unified check: whether doctor can generate prescriptions
  bool get canPrescribe {
    if (isLoading) return false; // prevent early access

    final now = DateTime.now().toUtc(); // 🔥 FIX

    if (_isTrialActive) return true;
    if (_isSubscribed && _subscriptionExpiry != null) {
      return _subscriptionExpiry!.toUtc().isAfter(now);
    }
    return false;
  }

  // ============================================================
  // INTERNAL HELPERS (NO notifyListeners HERE)
  // ============================================================

  void _setLoading(bool value) {
    _isLoading = value;
    // DO NOT notify here
  }

  // ============================================================
  // API ACTIONS — ONLY ONE notifyListeners PER METHOD
  // ============================================================

  /// Load trial + subscription from server
  /// 
  /// 
  



Future<void> loadStatus({bool force = false}) async {
  
  if (_isFetching) return;

  if (_statusLoaded && !force) return;

  _isFetching = true;

  _setLoading(true);
  //notifyListeners();

  try {
    // 🚨 ADD THIS HERE
    final token = await AuthService.getToken();

    if (token == null || token.isEmpty) {

 

      _isFetching = false;
      _setLoading(false);
      notifyListeners();

      return;
    }

    // ✅ SAFE TO CALL APIs NOW
   var  trial = await LicenseApiService.getTrialStatus();
   var  sub   = await LicenseApiService.getSubscriptionStatus();

 

// 🔥 If failed → retry with refreshed token
  if (trial == null || sub == null) {

    final refreshed =
        await AuthService.refreshAccessToken();

    if (refreshed) {
      trial = await LicenseApiService.getTrialStatus();
      sub   = await LicenseApiService.getSubscriptionStatus();
    }
  }
    if (trial != null) {
      _isTrialActive = trial["isTrialActive"] ?? false;
      _prescriptionCount = trial["prescriptionCount"] ?? 0;
      _trialEndDate = trial["trialEndDate"] != null
          ? DateTime.tryParse(trial["trialEndDate"])?.toUtc()
          : null;
    }

    if (sub != null) {
      final expiry = sub["expiryDate"];
      // 🚨 Detect invalid / stale response
  if (sub["isSubscribed"] == false && expiry != null) {
    final parsed = DateTime.tryParse(expiry);
    if (parsed != null && parsed.isBefore(DateTime.now().toUtc())) {
      print("⚠️ Stale subscription detected, forcing refresh...");
    }
  }

      _isSubscribed = sub["isSubscribed"] ?? false;
      _subscriptionExpiry = expiry != null
          ? DateTime.tryParse(expiry)?.toUtc()
          : null;

 

      _productId = sub["productId"];
    }

    _statusLoaded = true;

 

  } catch (e,stack) {
    print("❌ loadStatus error: $e");
  print(stack);
  } finally {
    _isFetching = false; // 🔥 IMPORTANT
    _setLoading(false);
    notifyListeners();
  }
}
  Future<void> logout() async {
  // Clear stored license / login data
  //_licenseData = null;
  //_isActive = false;

   // -----------------------------------
    // Clear JWT / Refresh Token
    // -----------------------------------
    await AuthService.logout();

  // If you use SharedPreferences clear it
   final prefs = await SharedPreferences.getInstance();
   await prefs.clear();

  notifyListeners();
}


  /// Increment prescription count (trial usage)
  Future<void> incrementPrescription() async {
    //_setLoading(true);

    try {
      final count = await LicenseApiService.incrementPrescriptionCount();
      if (count != null) {
        _prescriptionCount = count;
      }

      // Refresh status silently (loads subscription also)
      await loadStatus(); // loadStatus itself notifies ONCE
    } catch (e) {
      if (kDebugMode) print("❌ incrementPrescription error: $e");
    } finally {
     // _setLoading(false);
      notifyListeners(); // 🔥 One notify
    }
  }



  /// Save feedback before uninstall
  Future<void> saveFeedback(String feedback) async {
    _setLoading(true);

    try {
      await LicenseApiService.storeFeedbackBeforeUninstall(feedback);
    } catch (e) {
      if (kDebugMode) print("❌ saveFeedback error: $e");
    } finally {
      _setLoading(false);
      notifyListeners(); // ONE notify
    }
  }
}
