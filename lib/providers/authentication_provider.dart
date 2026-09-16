// import 'package:flutter/foundation.dart';

// import 'package:docautomations/services/auth_service.dart';

// class AuthenticationProvider extends ChangeNotifier {

// //===========================================================================
// // State
// //===========================================================================

// bool _isLoading = false;

// bool _isAuthenticated = false;

// String? _errorMessage;

// //===========================================================================
// // Getters
// //===========================================================================

// bool get isLoading => _isLoading;

// bool get isAuthenticated => _isAuthenticated;

// String? get errorMessage => _errorMessage;

// //===========================================================================
// // Initialize Authentication
// //
// // Called when the application starts.
// //
// // Checks whether a valid authentication session exists.
// //===========================================================================

// Future<void> initialize() async {


// _setLoading(true);

// _errorMessage = null;

// try {

//   _isAuthenticated =
//       await AuthService.isAuthenticated();

// } catch (_) {

//   _isAuthenticated = false;

// } finally {

//   _setLoading(false);

// }


// }

// //===========================================================================
// // Login
// //===========================================================================

// Future<bool> login({


// required String loginEmail,

// required String password,


// }) async {


// _setLoading(true);

// _errorMessage = null;

// try {

//   //---------------------------------------------------------
//   // Call Authentication Service
//   //---------------------------------------------------------

//   final result =
//       await AuthService.login(

//     loginEmail: loginEmail,

//     password: password,

//   );

//   //---------------------------------------------------------
//   // Login Successful
//   //---------------------------------------------------------

//   if (result["success"] == true) {

//     _isAuthenticated = true;

//     notifyListeners();

//     return true;

//   }

//   //---------------------------------------------------------
//   // Login Failed
//   //---------------------------------------------------------

//   _isAuthenticated = false;

//   _errorMessage =
//       result["message"] ??
//           "Login failed. Please check your credentials.";

//   notifyListeners();

//   return false;

// } catch (_) {

//   _isAuthenticated = false;

//   _errorMessage =
//       "Unable to login. Please try again.";

//   notifyListeners();

//   return false;

// } finally {

//   _setLoading(false);

// }


// }

// //===========================================================================
// // Logout
// //===========================================================================

// Future<void> logout() async {


// _setLoading(true);

// _errorMessage = null;

// try {

//   //---------------------------------------------------------
//   // Logout from server and clear local tokens
//   //---------------------------------------------------------

//   await AuthService.logout();

// } catch (_) {

//   //---------------------------------------------------------
//   // Even if server logout fails,
//   // AuthService should clear local authentication data.
//   //---------------------------------------------------------

// } finally {

//   _isAuthenticated = false;

//   _setLoading(false);

// }


// }

// //===========================================================================
// // Clear Error
// //===========================================================================

// void clearError() {


// _errorMessage = null;

// notifyListeners();


// }

// //===========================================================================
// // Internal Loading State
// //===========================================================================

// void _setLoading(
// bool value,
// ) {


// _isLoading = value;

// notifyListeners();


// }

// }




import 'package:flutter/foundation.dart';

import 'package:docautomations/services/auth_service.dart';


//=============================================================================
// AUTHENTICATION PROVIDER
//=============================================================================
//
// Responsibilities:
//
//   1. Maintain the current authentication state.
//   2. Initialize authentication when the application starts.
//   3. Perform doctor login.
//   4. Perform doctor logout.
//   5. Expose authentication state to the UI.
//
// This class does NOT:
//
//   - access SecureStorage directly
//   - access SharedPreferences
//   - call Dio directly
//   - load doctor profile
//   - load logo or signature
//   - load countries
//   - load patient data
//   - load prescription data
//   - perform application bootstrap
//
// AuthenticationProvider
//          ↓
//      AuthService
//          ↓
//        Dio
//          ↓
//       Backend
//
//=============================================================================

class AuthenticationProvider extends ChangeNotifier {

  //===========================================================================
  // AUTHENTICATION STATE
  //===========================================================================

  bool _isInitialized = false;

  bool _isAuthenticated = false;

  bool _isLoading = false;

  String? _errorMessage;


  //===========================================================================
  // PUBLIC GETTERS
  //===========================================================================

  bool get isInitialized => _isInitialized;

  bool get isAuthenticated => _isAuthenticated;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;


  //===========================================================================
  // INITIALIZE
  //===========================================================================
  //
  // Called by AppEntryPoint when the application starts.
  //
  // AuthService checks the locally stored access token.
  //
  //===========================================================================

  Future<void> initialize() async {

    if (_isInitialized) {
      return;
    }

    _setLoading(true);

    _clearError();

    try {

      _isAuthenticated =
          await AuthService.isAuthenticated();

      _isInitialized = true;

    } catch (error) {

      debugPrint(
        'Authentication initialization failed: $error',
      );

      _isAuthenticated = false;

      _errorMessage =
          'Unable to initialize authentication.';

      _isInitialized = true;

    } finally {

      _setLoading(false);

      notifyListeners();
    }
  }


  //===========================================================================
  // LOGIN
  //===========================================================================
  //
  // AuthService.login() returns the raw backend response:
  //
  // {
  //   "success": true,
  //   "message": "...",
  //   "data": {
  //      "accessToken": "...",
  //      "refreshToken": "..."
  //   }
  // }
  //
  // Therefore we must read:
  //
  //     result["success"]
  //     result["message"]
  //
  // rather than:
  //
  //     result.success
  //     result.message
  //
  //===========================================================================

  Future<bool> login({
    required String email,
    required String password,
  }) async {

    _setLoading(true);

    _clearError();

    try {

      final result = await AuthService.login(

        loginEmail: email,

        password: password,

      );


      //=======================================================================
      // SUCCESS / FAILURE
      //=======================================================================

      final success =
          result["success"] == true;


      if (!success) {

        _isAuthenticated = false;

        _errorMessage =
            result["message"]?.toString() ??
            'Login failed.';

        return false;
      }


      //=======================================================================
      // LOGIN SUCCESS
      //=======================================================================

      _isAuthenticated = true;

      _isInitialized = true;

      return true;

    } catch (error) {

      debugPrint(
        'Login failed: $error',
      );

      _isAuthenticated = false;

      _errorMessage =
          'Unable to login. Please try again.';

      return false;

    } finally {

      _setLoading(false);

      notifyListeners();
    }
  }


  //===========================================================================
  // LOGOUT
  //===========================================================================
  //
  // AuthService handles:
  //
  //   1. Informing the backend.
  //   2. Clearing local access token.
  //   3. Clearing local refresh token.
  //
  // Application cache and assets are handled separately by
  // ApplicationBootstrapper.
  //
  //===========================================================================

  Future<void> logout() async {

    _setLoading(true);

    _clearError();

    try {

      await AuthService.logout();

    } catch (error) {

      debugPrint(
        'Logout failed: $error',
      );

    } finally {

      _isAuthenticated = false;

      _isInitialized = true;

      _setLoading(false);

      notifyListeners();
    }
  }


  //===========================================================================
  // CLEAR AUTHENTICATION
  //===========================================================================
  //
  // Used when the session becomes invalid and the application needs to
  // return to the login state.
  //
  //===========================================================================

  Future<void> clearAuthentication() async {

    try {

      await AuthService.clearAuthenticationData();

    } catch (error) {

      debugPrint(
        'Unable to clear authentication data: $error',
      );

    } finally {

      _isAuthenticated = false;

      notifyListeners();
    }
  }


  //===========================================================================
  // REFRESH ACCESS TOKEN
  //===========================================================================
  //
  // Normally DioClient performs automatic token refresh.
  //
  // This method is available for an explicit refresh when required.
  //
  //===========================================================================

  Future<bool> refreshAccessToken() async {

    _clearError();

    try {

      final success =
          await AuthService.refreshAccessToken();


      if (!success) {

        _isAuthenticated = false;

        _errorMessage =
            'Your session has expired. Please login again.';

        notifyListeners();

        return false;
      }


      _isAuthenticated = true;

      notifyListeners();

      return true;

    } catch (error) {

      debugPrint(
        'Access token refresh failed: $error',
      );

      _isAuthenticated = false;

      _errorMessage =
          'Your session has expired. Please login again.';

      notifyListeners();

      return false;
    }
  }


  //===========================================================================
  // CLEAR ERROR
  //===========================================================================

  void clearError() {

    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;

    notifyListeners();
  }


  //===========================================================================
  // PRIVATE - LOADING STATE
  //===========================================================================

  void _setLoading(bool value) {

    if (_isLoading == value) {
      return;
    }

    _isLoading = value;

    notifyListeners();
  }


  //===========================================================================
  // PRIVATE - ERROR STATE
  //===========================================================================

  void _clearError() {

    _errorMessage = null;
  }
}



