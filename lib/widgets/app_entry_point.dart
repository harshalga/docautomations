
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:docautomations/application/application_bootstrapper.dart';
import 'package:docautomations/providers/authentication_provider.dart';

import 'package:docautomations/screens/auth/login_screen.dart';
import 'package:docautomations/screens/auth/registration_screen.dart';
import 'package:docautomations/screens/patient/patient_search_screen.dart';
import 'package:docautomations/screens/splash/splash_screen.dart';
import 'package:docautomations/datamodels/master/patient.dart';


//=============================================================================
// APPLICATION ENTRY POINT
//=============================================================================
//
// Responsibilities:
//
//   1. Start application initialization.
//   2. Show SplashScreen while initialization is in progress.
//   3. Initialize authentication.
//   4. Determine whether the doctor is authenticated.
//   5. Bootstrap authenticated application data.
//   6. Navigate to LoginScreen when authentication is unavailable.
//   7. Navigate to PatientSearchScreen after successful application bootstrap.
//   8. Handle bootstrap failures and provide retry.
//
// This widget does NOT:
//
//   - call APIs directly
//   - access SharedPreferences directly
//   - load doctor profile directly
//   - load logo/signature directly
//   - contain patient logic
//   - contain prescription logic
//   - contain business rules
//
//=============================================================================

class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}


//=============================================================================
// ENTRY POINT STATE
//=============================================================================

class _AppEntryPointState extends State<AppEntryPoint> {

  //-------------------------------------------------------------------------
  // STARTUP STATE
  //-------------------------------------------------------------------------

  _AppStartupState _startupState = _AppStartupState.initializing;

  String? _errorMessage;


  //-------------------------------------------------------------------------
  // LIFECYCLE
  //-------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApplication();
    });
  }


  //-------------------------------------------------------------------------
  // APPLICATION INITIALIZATION
  //-------------------------------------------------------------------------
  //
  // Authentication must be initialized first.
  //
  // Only after successful authentication do we bootstrap:
  //
  //   DoctorProfile
  //   PrescriptionLayout
  //   PrescriptionTheme
  //   Countries
  //   Logo
  //   Signature
  //
  //-------------------------------------------------------------------------

  Future<void> _initializeApplication() async {

    if (!mounted) return;

    setState(() {
      _startupState = _AppStartupState.initializing;
      _errorMessage = null;
    });

    try {

      //=======================================================================
      // STEP 1
      // Initialize authentication
      //=======================================================================

      final authenticationProvider =
          context.read<AuthenticationProvider>();

      await authenticationProvider.initialize();


      if (!mounted) return;


      //=======================================================================
      // STEP 2
      // Check authentication state
      //=======================================================================

      if (!authenticationProvider.isAuthenticated) {

        setState(() {
          _startupState = _AppStartupState.unauthenticated;
        });

        return;
      }


      //=======================================================================
      // STEP 3
      // Bootstrap authenticated application
      //=======================================================================

      final applicationBootstrapper =
          context.read<ApplicationBootstrapper>();

      await applicationBootstrapper.initialize();


      if (!mounted) return;


      //=======================================================================
      // STEP 4
      // Application is ready
      //=======================================================================

      setState(() {
        _startupState = _AppStartupState.ready;
      });

    } catch (error) {

      if (!mounted) return;

      debugPrint(
        'Application initialization failed: $error',
      );

      setState(() {
        _startupState = _AppStartupState.error;
        _errorMessage =
            'Unable to initialize the application.';
      });
    }
  }


  //-------------------------------------------------------------------------
  // LOGIN SUCCESS
  //-------------------------------------------------------------------------
  //
  // LoginScreen will notify AppEntryPoint after successful authentication.
  //
  // AppEntryPoint then performs the authenticated application bootstrap.
  //
  //-------------------------------------------------------------------------

  Future<void> _handleLoginSuccess() async {

    if (!mounted) return;

    setState(() {
      _startupState = _AppStartupState.initializing;
      _errorMessage = null;
    });

    try {

      final applicationBootstrapper =
          context.read<ApplicationBootstrapper>();

      await applicationBootstrapper.initialize(
        forceRefresh: true,
      );


      if (!mounted) return;

      setState(() {
        _startupState = _AppStartupState.ready;
      });

    } catch (error) {

      if (!mounted) return;

      debugPrint(
        'Application bootstrap after login failed: $error',
      );

      setState(() {
        _startupState = _AppStartupState.error;
        _errorMessage =
            'Unable to load your application data.';
      });
    }
  }
//-------------------------------------------------------------------------
// REGISTRATION REQUESTED
//-------------------------------------------------------------------------
//
// LoginScreen
//      ↓
// _handleRegistrationRequested()
//      ↓
// RegistrationScreen
//
//-------------------------------------------------------------------------
void _handleRegistrationRequested() {
  if (!mounted) return;

  setState(() {
    _startupState = _AppStartupState.registration;
    _errorMessage = null;
  });
}
  //-------------------------------------------------------------------------
  // REGISTRATION COMPLETED
  //-------------------------------------------------------------------------
  //
  // Registration should return the doctor to Login.
  //
  // We deliberately do not bootstrap the authenticated application here.
  // Registration and authentication remain separate concerns.
  //
  //-------------------------------------------------------------------------

  void _handleRegistrationCompleted() {

    if (!mounted) return;

    setState(() {
      _startupState = _AppStartupState.unauthenticated;
      _errorMessage = null;
    });
  }
  //-------------------------------------------------------------------------
// BACK TO LOGIN
//-------------------------------------------------------------------------
//
// RegistrationScreen
//      ↓
// Back
//      ↓
// LoginScreen
//
//-------------------------------------------------------------------------
void _handleBackToLogin() {
  if (!mounted) return;

  setState(() {
    _startupState = _AppStartupState.unauthenticated;
    _errorMessage = null;
  });
}

//-----------------------------------------------------------------------------
// PATIENT SELECTED
//-----------------------------------------------------------------------------
//
// Temporary handler.
//
// Once ConsultationScreen is created, this will become:
//
//     PatientSearchScreen
//             ↓
//     ConsultationScreen
//
//-----------------------------------------------------------------------------

void _handlePatientSelected(
  Patient patient,
) {

  // TODO:
  // Navigate/open ConsultationScreen for this patient.

  debugPrint(
    'Patient selected: ${patient.ppid}',
  );
}


//-----------------------------------------------------------------------------
// NEW PATIENT REQUESTED
//-----------------------------------------------------------------------------
//
// Temporary handler.
//
// Once PatientRegistrationScreen is created, this will become:
//
//     PatientSearchScreen
//             ↓
//     PatientRegistrationScreen
//
//-----------------------------------------------------------------------------

void _handleNewPatientRequested() {

  // TODO:
  // Open PatientRegistrationScreen.

  debugPrint(
    'New patient registration requested.',
  );
}


  //-------------------------------------------------------------------------
  // LOGOUT
  //-------------------------------------------------------------------------
  //
  // AuthenticationProvider handles authentication data.
  //
  // ApplicationBootstrapper handles application cache/assets.
  //
  // AppEntryPoint only coordinates the transition back to Login.
  //
  //-------------------------------------------------------------------------

  Future<void> _handleLogout() async {

    try {

      final authenticationProvider =
          context.read<AuthenticationProvider>();

      await authenticationProvider.logout();


      final applicationBootstrapper =
          context.read<ApplicationBootstrapper>();

      await applicationBootstrapper.clearCache();

    } catch (error) {

      debugPrint(
        'Logout cleanup failed: $error',
      );
    }


    if (!mounted) return;

    setState(() {
      _startupState = _AppStartupState.unauthenticated;
      _errorMessage = null;
    });
  }


  //-------------------------------------------------------------------------
  // BUILD
  //-------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {

    switch (_startupState) {

      //=======================================================================
      // INITIALIZING
      //=======================================================================

      case _AppStartupState.initializing:

        return const SplashScreen();


      //=======================================================================
      // NOT AUTHENTICATED
      //=======================================================================

      case _AppStartupState.unauthenticated:

        return LoginScreen(
          onLoginSuccess: _handleLoginSuccess,
          onRegisterRequested: _handleRegistrationRequested,
        );


      //=======================================================================
      // APPLICATION READY
      //=======================================================================

      case _AppStartupState.ready:

        return PatientSearchScreen(

          //------------------------------------------------------------------------- // Existing Patient Selected //------------------------------------------------------------------------- // // Later this will open the ConsultationScreen for the selected patient. // //-------------------------------------------------------------------------
           onPatientSelected: _handlePatientSelected, //------------------------------------------------------------------------- //
           // New Patient Requested //------------------------------------------------------------------------- // // Later this will open PatientRegistrationScreen. // //------------------------------------------------------------------------- 
           onNewPatientRequested: _handleNewPatientRequested,
          onLogout: _handleLogout,
        );


      //=======================================================================
      // INITIALIZATION ERROR
      //=======================================================================

      case _AppStartupState.error:

        return _ApplicationStartupErrorScreen(
          message: _errorMessage ??
              'Unable to start Prescriptor.',
          onRetry: _initializeApplication,
        );
      case _AppStartupState.registration:
        // TODO: Handle this case.
        return RegistrationScreen(
          onRegistrationCompleted: _handleRegistrationCompleted,
          onBackToLogin: _handleBackToLogin,
        );
    }
  }
}


//=============================================================================
// APPLICATION STARTUP STATE
//=============================================================================

enum _AppStartupState {

  initializing,

  unauthenticated,

  registration,

  ready,

  error,
}


//=============================================================================
// STARTUP ERROR SCREEN
//=============================================================================
//
// This screen is intentionally kept inside AppEntryPoint for now.
//
// It can later be moved to:
//     screens/common/application_error_screen.dart
//
// if it is reused elsewhere.
//=============================================================================

class _ApplicationStartupErrorScreen extends StatelessWidget {

  const _ApplicationStartupErrorScreen({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;


  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Scaffold(

      body: SafeArea(

        child: Center(

          child: Padding(

            padding: const EdgeInsets.all(32),

            child: ConstrainedBox(

              constraints: const BoxConstraints(
                maxWidth: 420,
              ),

              child: Column(

                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  //=============================================================
                  // ERROR ICON
                  //=============================================================

                  Icon(
                    Icons.cloud_off_rounded,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),

                  const SizedBox(height: 24),


                  //=============================================================
                  // TITLE
                  //=============================================================

                  Text(
                    'Unable to Start',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),


                  //=============================================================
                  // MESSAGE
                  //=============================================================

                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 28),


                  //=============================================================
                  // RETRY
                  //=============================================================

                  SizedBox(
                    width: double.infinity,

                    child: FilledButton.icon(

                      onPressed: onRetry,

                      icon: const Icon(
                        Icons.refresh_rounded,
                      ),

                      label: const Text(
                        'Retry',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

