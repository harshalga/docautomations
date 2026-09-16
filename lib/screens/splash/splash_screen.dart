import 'package:flutter/material.dart';


//=============================================================================
// SPLASH SCREEN
//=============================================================================
//
// This screen is displayed while AppEntryPoint initializes the application.
//
// Responsibilities:
//
//   - Display Prescriptor branding.
//   - Provide visual feedback while application initialization is running.
//
// This screen does NOT:
//
//   - initialize authentication
//   - call APIs
//   - access SharedPreferences
//   - load doctor data
//   - load application master data
//   - perform navigation
//
// AppEntryPoint owns all of those responsibilities.
//
//=============================================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}


//=============================================================================
// SPLASH SCREEN STATE
//=============================================================================

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  //-------------------------------------------------------------------------
  // ANIMATION
  //-------------------------------------------------------------------------

  late final AnimationController _animationController;

  late final Animation<double> _fadeAnimation;

  late final Animation<double> _scaleAnimation;


  //-------------------------------------------------------------------------
  // INITIALIZATION
  //-------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1200,
      ),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.90,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();
  }


  //-------------------------------------------------------------------------
  // DISPOSE
  //-------------------------------------------------------------------------

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }


  //-------------------------------------------------------------------------
  // BUILD
  //-------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,

      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,

            child: ScaleTransition(
              scale: _scaleAnimation,

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  //=============================================================
                  // APPLICATION LOGO
                  //=============================================================

                  _buildLogo(theme),

                  const SizedBox(height: 28),


                  //=============================================================
                  // APPLICATION NAME
                  //=============================================================

                  Text(
                    'PRESCRIPTOR',

                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 8),


                  //=============================================================
                  // APPLICATION DESCRIPTION
                  //=============================================================

                  Text(
                    'Medical Prescription Management',

                    textAlign: TextAlign.center,

                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 40),


                  //=============================================================
                  // LOADING INDICATOR
                  //=============================================================

                  SizedBox(
                    width: 28,
                    height: 28,

                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,

                      color: theme.colorScheme.primary,
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


  //-------------------------------------------------------------------------
  // LOGO
  //-------------------------------------------------------------------------
  //
  // We deliberately use an Icon for now.
  //
  // Once the final Prescriptor application logo/asset is finalized, this
  // method can be changed to use an Image.asset() without affecting the
  // splash screen architecture.
  //
  //-------------------------------------------------------------------------

  Widget _buildLogo(ThemeData theme) {

    return Container(
      width: 100,
      height: 100,

      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),

      child: 
      //Icon(
     //   Icons.medical_services_rounded,

    //    size: 56,

   //     color: theme.colorScheme.onPrimaryContainer,
   //   )
      Image.asset(
                    'assets/icon/app_logo.png',
                    width: 96,
                    height: 96,
                    fit: BoxFit.contain,
                  ),
    );
  }
}