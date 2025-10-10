import 'package:docautomations/services/license_api_service.dart';
import 'package:flutter/foundation.dart';


class LicenseProvider with ChangeNotifier {


  // =======================
  // State variables
  // =======================
  bool _isLoading = false;

  // Trial state
  bool _isTrialActive = false;
  int _prescriptionCount = 0;
  DateTime? _trialEndDate;

  // Subscription state
  bool _isSubscribed = false;
  DateTime? _subscriptionExpiry;
  String? _productId;

  // =======================
  // Getters
  // =======================

  bool get isLoading => _isLoading;

  set isLoading(bool value) {        // ✅ public setter
    _isLoading = value;
    notifyListeners();
  }

  bool get isTrialActive => _isTrialActive;
  int get prescriptionCount => _prescriptionCount;
  DateTime? get trialEndDate => _trialEndDate;

  bool get isSubscribed => _isSubscribed;
  DateTime? get subscriptionExpiry => _subscriptionExpiry;
  String? get productId => _productId;

  /// Unified check: whether doctor can generate prescriptions
  bool get canPrescribe {
    if (_isTrialActive) return true;
    if (_isSubscribed && _subscriptionExpiry != null) {
      return _subscriptionExpiry!.isAfter(DateTime.now());
    }
    return false;
  }

  /// 🔄 Call this when app starts
  /// trial/subscription status automatically refreshes when the app opens (or comes back from background)
  // Future<void> init() async {
  //   try {
  //     print("LicenseProvider init called!");
  //   await loadStatus();
  //   print("LicenseProvider init after loadStatus ");
  //   }
  //   catch(e,st)
  //   {debugPrint("LicenseProvider init error: $e\n$st");}
  // }

  // /// 🔄 Refresh periodically or on lifecycle resume
  // /// trial/subscription status automatically refreshes when the app opens (or comes back from background)
  // Future<void> refreshStatus() async {
  //   await loadStatus();
  // }


// =======================
  // Actions
  // =======================

  /// Load both trial + subscription status from server
  /// Load trial + subscription status together
  Future<void> loadStatus() async {
     _isLoading = true;
    notifyListeners();
    try {
    final trial = await LicenseApiService.getTrialStatus();
    if (trial != null) {
      _isTrialActive = trial["isTrialActive"] ?? false;
      _prescriptionCount = trial["prescriptionCount"] ?? 0;
      _trialEndDate = trial["trialEndDate"] != null
          ? DateTime.tryParse(trial["trialEndDate"])
          : null;
    }

    final sub = await LicenseApiService.getSubscriptionStatus();
    if (sub != null) {
      _isSubscribed = sub["isSubscribed"] ?? false;
      _subscriptionExpiry = sub["expiryDate"] != null
          ? DateTime.tryParse(sub["expiryDate"])
          : null;
      _productId = sub["productId"];
    }
    }
    catch(e)
     {
      if (kDebugMode) {
        print("❌ Error loading license status: $e");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  //Save the feedback 
Future<void> saveFeedback(String feedback) async {
isLoading  = true;
    //notifyListeners();
     try {
     await LicenseApiService.storeFeedbackBeforeUninstall(feedback);
    
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error incrementing prescription: $e");
      }
    } finally {
      isLoading = false;
      //notifyListeners();
    }
}

  /// Increment prescription count (trial usage)
  Future<void> incrementPrescription() async {
     _isLoading = true;
    notifyListeners();
     try {
    final int? prescCount = await LicenseApiService.incrementPrescriptionCount();
    if (prescCount!=null) {
      _prescriptionCount=prescCount;
      // trial may expire after increment
      await loadStatus();
    }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error incrementing prescription: $e");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Activate subscription (after backend verifies purchase)
  Future<bool> activateSubscription(
      String productId, String transactionId, DateTime expiryDate,String platform,String receiptData )  async {
    bool success = false;
         _isLoading = true;
    notifyListeners();
     try {
     success = await LicenseApiService.activateSubscription(
      productId,
      transactionId,
      expiryDate,
      platform,
      receiptData
    );
    if (success) {
      await loadStatus();
    }
    return success;
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error activating subscription: $e");
        return false;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
      return success;
    }
  }

  // /// Simple helper to check if user can generate prescriptions
  // bool get canPrescribe {
  //   if (_isTrialActive) return true;
  //   if (_isSubscribed && _subscriptionExpiry != null) {
  //     return _subscriptionExpiry!.isAfter(DateTime.now());
  //   }
  //   return false;
  // }
}
