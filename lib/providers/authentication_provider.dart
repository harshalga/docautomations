import 'package:flutter/foundation.dart';

import 'package:docautomations/services/auth_service.dart';

class AuthenticationProvider extends ChangeNotifier {

//===========================================================================
// State
//===========================================================================

bool _isLoading = false;

bool _isAuthenticated = false;

String? _errorMessage;

//===========================================================================
// Getters
//===========================================================================

bool get isLoading => _isLoading;

bool get isAuthenticated => _isAuthenticated;

String? get errorMessage => _errorMessage;

//===========================================================================
// Initialize Authentication
//
// Called when the application starts.
//
// Checks whether a valid authentication session exists.
//===========================================================================

Future<void> initialize() async {


_setLoading(true);

_errorMessage = null;

try {

  _isAuthenticated =
      await AuthService.isAuthenticated();

} catch (_) {

  _isAuthenticated = false;

} finally {

  _setLoading(false);

}


}

//===========================================================================
// Login
//===========================================================================

Future<bool> login({


required String loginEmail,

required String password,


}) async {


_setLoading(true);

_errorMessage = null;

try {

  //---------------------------------------------------------
  // Call Authentication Service
  //---------------------------------------------------------

  final result =
      await AuthService.login(

    loginEmail: loginEmail,

    password: password,

  );

  //---------------------------------------------------------
  // Login Successful
  //---------------------------------------------------------

  if (result["success"] == true) {

    _isAuthenticated = true;

    notifyListeners();

    return true;

  }

  //---------------------------------------------------------
  // Login Failed
  //---------------------------------------------------------

  _isAuthenticated = false;

  _errorMessage =
      result["message"] ??
          "Login failed. Please check your credentials.";

  notifyListeners();

  return false;

} catch (_) {

  _isAuthenticated = false;

  _errorMessage =
      "Unable to login. Please try again.";

  notifyListeners();

  return false;

} finally {

  _setLoading(false);

}


}

//===========================================================================
// Logout
//===========================================================================

Future<void> logout() async {


_setLoading(true);

_errorMessage = null;

try {

  //---------------------------------------------------------
  // Logout from server and clear local tokens
  //---------------------------------------------------------

  await AuthService.logout();

} catch (_) {

  //---------------------------------------------------------
  // Even if server logout fails,
  // AuthService should clear local authentication data.
  //---------------------------------------------------------

} finally {

  _isAuthenticated = false;

  _setLoading(false);

}


}

//===========================================================================
// Clear Error
//===========================================================================

void clearError() {


_errorMessage = null;

notifyListeners();


}

//===========================================================================
// Internal Loading State
//===========================================================================

void _setLoading(
bool value,
) {


_isLoading = value;

notifyListeners();


}

}
