import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:docautomations/controllers/doctor_registration_controller.dart';
import 'package:docautomations/datamodels/master/country.dart';
import 'package:docautomations/datamodels/request/doctor_registration_request.dart';
import 'package:docautomations/repositories/reference_data_repository.dart';


//=============================================================================
// REGISTRATION SCREEN
//=============================================================================
//
// Responsibilities:
//
//   • Display the complete doctor registration form.
//   • Collect data required by DoctorRegistrationRequest.
//   • Load the country master.
//   • Validate user input.
//   • Submit registration through DoctorRegistrationController.
//   • Notify AppEntryPoint after successful registration.
//
// This screen does NOT:
//
//   • call Dio directly
//   • call DoctorApiService directly
//   • call AuthService
//   • access secure storage
//   • access SharedPreferences
//   • perform application bootstrap
//   • perform navigation
//
// Flow:
//
//   RegistrationScreen
//          ↓
//   DoctorRegistrationController
//          ↓
//   DoctorRepository
//          ↓
//   DoctorApiService
//          ↓
//   Backend
//
//=============================================================================

class RegistrationScreen extends StatefulWidget {

  const RegistrationScreen({
    super.key,
    required this.onRegistrationCompleted,
    required this.onBackToLogin,
  });


  //-------------------------------------------------------------------------
  // CALLBACKS
  //-------------------------------------------------------------------------

  final VoidCallback onRegistrationCompleted;

  final VoidCallback onBackToLogin;


  @override
  State<RegistrationScreen> createState() =>
      _RegistrationScreenState();
}


//=============================================================================
// REGISTRATION SCREEN STATE
//=============================================================================

class _RegistrationScreenState
    extends State<RegistrationScreen> {

  //-------------------------------------------------------------------------
  // FORM
  //-------------------------------------------------------------------------

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();


  //-------------------------------------------------------------------------
  // PERSONAL INFORMATION
  //-------------------------------------------------------------------------

  final TextEditingController _doctorNameController =
      TextEditingController();

  final TextEditingController _qualificationController =
      TextEditingController();

  final TextEditingController _specializationController =
      TextEditingController();


  //-------------------------------------------------------------------------
  // MEDICAL REGISTRATION
  //-------------------------------------------------------------------------

  final TextEditingController
      _medicalRegistrationNumberController =
          TextEditingController();

  final TextEditingController
      _registrationAuthorityController =
          TextEditingController();


  //-------------------------------------------------------------------------
  // CLINIC INFORMATION
  //-------------------------------------------------------------------------

  final TextEditingController _clinicNameController =
      TextEditingController();

  final TextEditingController _clinicAddressController =
      TextEditingController();

  final TextEditingController _cityController =
      TextEditingController();

  final TextEditingController _stateController =
      TextEditingController();

  final TextEditingController _pincodeController =
      TextEditingController();


  //-------------------------------------------------------------------------
  // CONTACT INFORMATION
  //-------------------------------------------------------------------------

  final TextEditingController _contactController =
      TextEditingController();

  final TextEditingController
      _alternateContactController =
          TextEditingController();

  final TextEditingController _websiteController =
      TextEditingController();


  //-------------------------------------------------------------------------
  // LOGIN INFORMATION
  //-------------------------------------------------------------------------

  final TextEditingController _loginEmailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final TextEditingController
      _confirmPasswordController =
          TextEditingController();


  //-------------------------------------------------------------------------
  // COUNTRY
  //-------------------------------------------------------------------------

  Country? _selectedCountry;


  List<Country> _countries = [];

  bool _isLoadingCountries = true;

  String? _countryError;


  //-------------------------------------------------------------------------
  // PASSWORD VISIBILITY
  //-------------------------------------------------------------------------

  bool _obscurePassword = true;

  bool _obscureConfirmPassword = true;


  //-------------------------------------------------------------------------
  // LIFECYCLE
  //-------------------------------------------------------------------------

  @override
  void initState() {

    super.initState();

    _loadCountries();
  }


  @override
  void dispose() {

    _doctorNameController.dispose();
    _qualificationController.dispose();
    _specializationController.dispose();

    _medicalRegistrationNumberController.dispose();
    _registrationAuthorityController.dispose();

    _clinicNameController.dispose();
    _clinicAddressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();

    _contactController.dispose();
    _alternateContactController.dispose();
    _websiteController.dispose();

    _loginEmailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }


  //-------------------------------------------------------------------------
  // LOAD COUNTRIES
  //-------------------------------------------------------------------------
  //
  // Countries are reference/master data.
  //
  // ReferenceDataRepository is already registered in main.dart and therefore
  // can be obtained through Provider.
  //
  //-------------------------------------------------------------------------

  Future<void> _loadCountries() async {

    try {

      final repository =
          context.read<ReferenceDataRepository>();

      final countries =
          await repository.fetchCountries();


      if (!mounted) {
        return;
      }


      setState(() {

        _countries = countries;

        _isLoadingCountries = false;

        _countryError = null;
      });

    } catch (e) {

      if (!mounted) {
        return;
      }


      setState(() {

        _isLoadingCountries = false;

        _countryError =
            "Unable to load countries.";
      });
    }
  }


  //-------------------------------------------------------------------------
  // REGISTRATION
  //-------------------------------------------------------------------------

  Future<void> _register() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }


    //-------------------------------------------------------------------------
    // Country validation
    //-------------------------------------------------------------------------

    if (_selectedCountry == null) {

      setState(() {
        _countryError =
            "Please select your country.";
      });

      return;
    }


    FocusScope.of(context).unfocus();


    final controller =
        context.read<DoctorRegistrationController>();


    controller.clearError();


    //-------------------------------------------------------------------------
    // BUILD REQUEST
    //-------------------------------------------------------------------------

    final request =
        DoctorRegistrationRequest(

      //=======================================================================
      // Personal Information
      //=======================================================================

      doctorName:
          _doctorNameController.text.trim(),

      specialization:
          _specializationController.text.trim(),

      qualification:
          _qualificationController.text.trim(),


      //=======================================================================
      // Clinic Information
      //=======================================================================

      clinicName:
          _clinicNameController.text.trim(),

      clinicAddress:
          _clinicAddressController.text.trim(),

      city:
          _cityController.text.trim(),

      state:
          _stateController.text.trim(),

      pincode:
          _pincodeController.text.trim(),


      //=======================================================================
      // Contact Information
      //=======================================================================

      contact:
          _contactController.text.trim(),

      alternateContact:
          _alternateContactController.text.trim(),

      website:
          _websiteController.text.trim(),


      //=======================================================================
      // Login Information
      //=======================================================================

      loginEmail:
          _loginEmailController.text
              .trim()
              .toLowerCase(),

      password:
          _passwordController.text,


      //=======================================================================
      // Medical Registration
      //=======================================================================

      medicalRegistrationNumber:
          _medicalRegistrationNumberController.text
              .trim()
              .toUpperCase(),

      registrationAuthority:
          _registrationAuthorityController.text
              .trim(),

      countryId:
          _countryId(_selectedCountry!),

      //=======================================================================
      // Logo
      //=======================================================================
      //
      // Logo selection/upload can be added once the new asset picker flow
      // is introduced.
      //
      //=======================================================================

      logo:
          null,
    );


    //-------------------------------------------------------------------------
    // SUBMIT
    //-------------------------------------------------------------------------

    final success =
        await controller.register(request);


    if (!mounted) {
      return;
    }


    if (!success) {
      return;
    }


    //-------------------------------------------------------------------------
    // REGISTRATION COMPLETED
    //-------------------------------------------------------------------------

    widget.onRegistrationCompleted();
  }


  //-------------------------------------------------------------------------
  // COUNTRY ID
  //-------------------------------------------------------------------------
  //
  // The exact Country model should expose its MongoDB country identifier.
  //
  // This helper keeps the request construction in one place.
  //
  //-------------------------------------------------------------------------

  String _countryId(Country country) {

    return country.id.toString();
  }


  //-------------------------------------------------------------------------
  // BUILD
  //-------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {

    final theme =
        Theme.of(context);


    return Scaffold(

      appBar: AppBar(

        title:
            const Text(
          'Doctor Registration',
        ),

        leading:
            IconButton(

          tooltip:
              'Back to Login',

          onPressed:
              context
                  .watch<DoctorRegistrationController>()
                  .isLoading

                  ? null

                  : widget.onBackToLogin,

          icon:
              const Icon(
            Icons.arrow_back_rounded,
          ),
        ),
      ),


      body:
          SafeArea(

        child:
            Consumer<DoctorRegistrationController>(

          builder:
              (
                context,
                controller,
                child,
              ) {

            return SingleChildScrollView(

              padding:
                  const EdgeInsets.fromLTRB(
                24,
                24,
                24,
                48,
              ),


              child:
                  Center(

                child:
                    ConstrainedBox(

                  constraints:
                      const BoxConstraints(
                    maxWidth: 650,
                  ),


                  child:
                      Form(

                    key:
                        _formKey,


                    child:
                        Column(

                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,


                      children: [

                        //=====================================================
                        // HEADER
                        //=====================================================

                        _buildHeader(theme),

                        const SizedBox(
                          height: 32,
                        ),


                        //=====================================================
                        // SERVER ERROR
                        //=====================================================

                        if (controller.errorMessage != null)
                          _buildErrorMessage(
                            theme,
                            controller.errorMessage!,
                          ),


                        if (controller.errorMessage != null)
                          const SizedBox(
                            height: 20,
                          ),


                        //=====================================================
                        // PERSONAL INFORMATION
                        //=====================================================

                        _buildSectionTitle(
                          theme,
                          'Personal Information',
                        ),

                        const SizedBox(
                          height: 16,
                        ),


                        _buildTextField(

                          controller:
                              _doctorNameController,

                          label:
                              'Doctor Name',

                          icon:
                              Icons.person_outline_rounded,

                          enabled:
                              !controller.isLoading,

                          capitalization:
                              TextCapitalization.words,

                          validator:
                              _requiredValidator,
                        ),


                        const SizedBox(
                          height: 16,
                        ),


                        _buildTextField(

                          controller:
                              _qualificationController,

                          label:
                              'Qualification',

                          icon:
                              Icons.school_outlined,

                          enabled:
                              !controller.isLoading,

                          capitalization:
                              TextCapitalization.words,

                          validator:
                              _requiredValidator,
                        ),


                        const SizedBox(
                          height: 16,
                        ),


                        _buildTextField(

                          controller:
                              _specializationController,

                          label:
                              'Specialization',

                          icon:
                              Icons.medical_information_outlined,

                          enabled:
                              !controller.isLoading,

                          capitalization:
                              TextCapitalization.words,

                          validator:
                              _requiredValidator,
                        ),


                        const SizedBox(
                          height: 28,
                        ),


                        //=====================================================
                        // MEDICAL REGISTRATION
                        //=====================================================

                        _buildSectionTitle(
                          theme,
                          'Medical Registration',
                        ),

                        const SizedBox(
                          height: 16,
                        ),


                        _buildTextField(

                          controller:
                              _medicalRegistrationNumberController,

                          label:
                              'Medical Registration Number',

                          icon:
                              Icons.badge_outlined,

                          enabled:
                              !controller.isLoading,

                          capitalization:
                              TextCapitalization.characters,

                          validator:
                              _requiredValidator,
                        ),


                        const SizedBox(
                          height: 16,
                        ),


                        _buildTextField(

                          controller:
                              _registrationAuthorityController,

                          label:
                              'Registration Authority',

                          hint:
                              'e.g. State Medical Council',

                          icon:
                              Icons.account_balance_outlined,

                          enabled:
                              !controller.isLoading,

                          capitalization:
                              TextCapitalization.words,

                          validator:
                              _requiredValidator,
                        ),


                        const SizedBox(
                          height: 16,
                        ),


                        // Country
                        _buildCountryDropdown(
                          theme,
                          controller,
                        ),


                        const SizedBox(
                          height: 28,
                        ),


                        //=====================================================
                        // CLINIC INFORMATION
                        //=====================================================

                        _buildSectionTitle(
                          theme,
                          'Clinic Information',
                        ),

                        const SizedBox(
                          height: 16,
                        ),


                        _buildTextField(

                          controller:
                              _clinicNameController,

                          label:
                              'Clinic Name',

                          icon:
                              Icons.local_hospital_outlined,

                          enabled:
                              !controller.isLoading,

                          capitalization:
                              TextCapitalization.words,

                          validator:
                              _requiredValidator,
                        ),


                        const SizedBox(
                          height: 16,
                        ),


                        _buildTextField(

                          controller:
                              _clinicAddressController,

                          label:
                              'Clinic Address',

                          icon:
                              Icons.location_on_outlined,

                          enabled:
                              !controller.isLoading,

                          capitalization:
                              TextCapitalization.sentences,

                          minLines:
                              2,

                          maxLines:
                              4,

                          validator:
                              _requiredValidator,
                        ),


                        const SizedBox(
                          height: 16,
                        ),


                        _buildTextField(

                          controller:
                              _cityController,

                          label:
                              'City',

                          icon:
                              Icons.location_city_outlined,

                          enabled:
                              !controller.isLoading,

                          capitalization:
                              TextCapitalization.words,

                          validator:
                              _requiredValidator,
                        ),


                        const SizedBox(
                          height: 16,
                        ),


                        _buildTextField(

                          controller:
                              _stateController,

                          label:
                              'State',

                          icon:
                              Icons.map_outlined,

                          enabled:
                              !controller.isLoading,

                          capitalization:
                              TextCapitalization.words,

                          validator:
                              _requiredValidator,
                        ),


                        const SizedBox(
                          height: 16,
                        ),


                        _buildTextField(

                          controller:
                              _pincodeController,

                          label:
                              'PIN Code',

                          icon:
                              Icons.pin_drop_outlined,

                          enabled:
                              !controller.isLoading,

                          keyboardType:
                              TextInputType.number,

                          validator:
                              _pincodeValidator,
                        ),


                        const SizedBox(
                          height: 28,
                        ),


                        //=====================================================
                        // CONTACT INFORMATION
                        //=====================================================

                        _buildSectionTitle(
                          theme,
                          'Contact Information',
                        ),

                        const SizedBox(
                          height: 16,
                        ),


                        _buildTextField(

                          controller:
                              _contactController,

                          label:
                              'Contact Number',

                          icon:
                              Icons.phone_outlined,

                          enabled:
                              !controller.isLoading,

                          keyboardType:
                              TextInputType.phone,

                          validator:
                              _mobileValidator,
                        ),


                        const SizedBox(
                          height: 16,
                        ),


                        _buildTextField(

                          controller:
                              _alternateContactController,

                          label:
                              'Alternate Contact Number',

                          icon:
                              Icons.phone_android_outlined,

                          enabled:
                              !controller.isLoading,

                          keyboardType:
                              TextInputType.phone,
                        ),


                        const SizedBox(
                          height: 16,
                        ),


                        _buildTextField(

                          controller:
                              _websiteController,

                          label:
                              'Website',

                          hint:
                              'https://example.com',

                          icon:
                              Icons.language_outlined,

                          enabled:
                              !controller.isLoading,

                          keyboardType:
                              TextInputType.url,

                          validator:
                              _websiteValidator,
                        ),


                        const SizedBox(
                          height: 28,
                        ),


                        //=====================================================
                        // LOGIN INFORMATION
                        //=====================================================

                        _buildSectionTitle(
                          theme,
                          'Login Information',
                        ),

                        const SizedBox(
                          height: 16,
                        ),


                        _buildTextField(

                          controller:
                              _loginEmailController,

                          label:
                              'Login Email',

                          icon:
                              Icons.email_outlined,

                          enabled:
                              !controller.isLoading,

                          keyboardType:
                              TextInputType.emailAddress,

                          autocorrect:
                              false,

                          validator:
                              _emailValidator,
                        ),


                        const SizedBox(
                          height: 16,
                        ),


                        _buildPasswordField(
                          controller:
                              _passwordController,

                          label:
                              'Password',

                          obscure:
                              _obscurePassword,

                          enabled:
                              !controller.isLoading,

                          onToggle:
                              () {

                            setState(() {

                              _obscurePassword =
                                  !_obscurePassword;
                            });
                          },

                          validator:
                              _passwordValidator,
                        ),


                        const SizedBox(
                          height: 16,
                        ),


                        _buildPasswordField(
                          controller:
                              _confirmPasswordController,

                          label:
                              'Confirm Password',

                          obscure:
                              _obscureConfirmPassword,

                          enabled:
                              !controller.isLoading,

                          onToggle:
                              () {

                            setState(() {

                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },

                          validator:
                              (value) {

                            if (value == null ||
                                value.isEmpty) {

                              return
                                  'Please confirm your password';
                            }


                            if (value !=
                                _passwordController.text) {

                              return
                                  'Passwords do not match';
                            }


                            return null;
                          },
                        ),


                        const SizedBox(
                          height: 32,
                        ),


                        //=====================================================
                        // REGISTER BUTTON
                        //=====================================================

                        SizedBox(

                          height:
                              54,

                          child:
                              FilledButton.icon(

                            onPressed:
                                controller.isLoading
                                    ? null
                                    : _register,

                            icon:
                                controller.isLoading

                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                        ),
                                      )

                                    : const Icon(
                                        Icons.person_add_alt_1_rounded,
                                      ),

                            label:
                                Text(
                              controller.isLoading
                                  ? 'Creating Account...'
                                  : 'Create Doctor Account',

                              style:
                                  const TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                          ),
                        ),


                        const SizedBox(
                          height: 16,
                        ),


                        //=====================================================
                        // BACK TO LOGIN
                        //=====================================================

                        TextButton(

                          onPressed:
                              controller.isLoading
                                  ? null
                                  : widget.onBackToLogin,

                          child:
                              const Text(
                            'Already have an account? Login',

                            style:
                                TextStyle(
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  //-------------------------------------------------------------------------
  // COUNTRY DROPDOWN
  //-------------------------------------------------------------------------

  Widget _buildCountryDropdown(
    ThemeData theme,
    DoctorRegistrationController controller,
  ) {

    if (_isLoadingCountries) {

      return const InputDecorator(

        decoration:
            InputDecoration(
          labelText:
              'Country',
          prefixIcon:
              Icon(
            Icons.public_outlined,
          ),
        ),

        child:
            Row(
          children: [

            SizedBox(
              width: 18,
              height: 18,
              child:
                  CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),

            SizedBox(
              width: 12,
            ),

            Text(
              'Loading countries...',
            ),
          ],
        ),
      );
    }


    if (_countryError != null) {

      return Column(

        crossAxisAlignment:
            CrossAxisAlignment.stretch,

        children: [

          InputDecorator(

            decoration:
                InputDecoration(

              labelText:
                  'Country',

              prefixIcon:
                  const Icon(
                Icons.public_outlined,
              ),

              errorText:
                  _countryError,
            ),

            child:
                const Text(
              'Unable to load countries',
            ),
          ),


          const SizedBox(
            height: 8,
          ),


          Align(

            alignment:
                Alignment.centerLeft,

            child:
                TextButton.icon(

              onPressed:
                  controller.isLoading
                      ? null
                      : _loadCountries,

              icon:
                  const Icon(
                Icons.refresh_rounded,
              ),

              label:
                  const Text(
                'Retry',
              ),
            ),
          ),
        ],
      );
    }


    return DropdownButtonFormField<Country>(

      value:
          _selectedCountry,

      isExpanded:
          true,

      decoration:
          const InputDecoration(

        labelText:
            'Country',

        prefixIcon:
            Icon(
          Icons.public_outlined,
        ),
      ),


      items:
          _countries.map(
            (country) {

          return DropdownMenuItem<Country>(

            value:
                country,

            child:
                Text(
              _countryName(country),
            ),
          );
        },
      ).toList(),


      onChanged:
          controller.isLoading
              ? null
              : (country) {

                  setState(() {

                    _selectedCountry =
                        country;

                    _countryError =
                        null;
                  });
                },


      validator:
          (value) {

        if (value == null) {
          return 'Please select your country';
        }

        return null;
      },
    );
  }


  //-------------------------------------------------------------------------
  // COUNTRY NAME
  //-------------------------------------------------------------------------
  //
  // Kept in one helper because the exact display property of Country should
  // remain isolated here.
  //
  // If your Country model uses a different property name, only this helper
  // needs to change.
  //
  //-------------------------------------------------------------------------

  String _countryName(Country country) {

    return country.countryName;
  }


  //-------------------------------------------------------------------------
  // GENERIC TEXT FIELD
  //-------------------------------------------------------------------------

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,

    String? hint,

    TextCapitalization capitalization =
        TextCapitalization.none,

    TextInputType? keyboardType,

    bool autocorrect = true,

    int minLines = 1,

    int maxLines = 1,

    String? Function(String?)? validator,
  }) {

    return TextFormField(

      controller:
          controller,

      enabled:
          enabled,

      textCapitalization:
          capitalization,

      keyboardType:
          keyboardType,

      autocorrect:
          autocorrect,

      minLines:
          minLines,

      maxLines:
          maxLines,

      decoration:
          InputDecoration(

        labelText:
            label,

        hintText:
            hint,

        prefixIcon:
            Icon(icon),
      ),

      validator:
          validator,
    );
  }


  //-------------------------------------------------------------------------
  // PASSWORD FIELD
  //-------------------------------------------------------------------------

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required bool enabled,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {

    return TextFormField(

      controller:
          controller,

      enabled:
          enabled,

      obscureText:
          obscure,

      autocorrect:
          false,

      decoration:
          InputDecoration(

        labelText:
            label,

        prefixIcon:
            const Icon(
          Icons.lock_outline_rounded,
        ),

        suffixIcon:
            IconButton(

          onPressed:
              enabled
                  ? onToggle
                  : null,

          icon:
              Icon(
            obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
      ),

      validator:
          validator,
    );
  }


  //-------------------------------------------------------------------------
  // HEADER
  //-------------------------------------------------------------------------

  Widget _buildHeader(
    ThemeData theme,
  ) {

    return Column(

      children: [

        Container(

          width:
              82,

          height:
              82,

          decoration:
              BoxDecoration(

            color:
                theme.colorScheme.primaryContainer,

            shape:
                BoxShape.circle,
          ),

          child:
              Icon(

            Icons.medical_services_rounded,

            size:
                44,

            color:
                theme.colorScheme.onPrimaryContainer,
          ),
        ),


        const SizedBox(
          height: 18,
        ),


        Text(

          'Create Your Prescriptor Account',

          textAlign:
              TextAlign.center,

          style:
              theme.textTheme.headlineSmall?.copyWith(
            fontWeight:
                FontWeight.w800,
          ),
        ),


        const SizedBox(
          height: 8,
        ),


        Text(

          'Register your doctor account to start using Prescriptor.',

          textAlign:
              TextAlign.center,

          style:
              theme.textTheme.bodyMedium?.copyWith(

            color:
                theme.colorScheme.onSurfaceVariant,

            height:
                1.4,
          ),
        ),
      ],
    );
  }


  //-------------------------------------------------------------------------
  // SECTION TITLE
  //-------------------------------------------------------------------------

  Widget _buildSectionTitle(
    ThemeData theme,
    String title,
  ) {

    return Text(

      title,

      style:
          theme.textTheme.titleMedium?.copyWith(

        fontWeight:
            FontWeight.w800,
      ),
    );
  }


  //-------------------------------------------------------------------------
  // ERROR MESSAGE
  //-------------------------------------------------------------------------

  Widget _buildErrorMessage(
    ThemeData theme,
    String message,
  ) {

    return Container(

      padding:
          const EdgeInsets.all(14),

      decoration:
          BoxDecoration(

        color:
            theme.colorScheme.errorContainer,

        borderRadius:
            BorderRadius.circular(12),

        border:
            Border.all(

          color:
              theme.colorScheme.error
                  .withValues(alpha: 0.30),
        ),
      ),


      child:
          Row(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Icon(

            Icons.error_outline_rounded,

            color:
                theme.colorScheme.onErrorContainer,
          ),


          const SizedBox(
            width: 12,
          ),


          Expanded(

            child:
                Text(

              message,

              style:
                  TextStyle(

                color:
                    theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }


  //-------------------------------------------------------------------------
  // VALIDATORS
  //-------------------------------------------------------------------------

  String? _requiredValidator(
    String? value,
  ) {

    if (value == null ||
        value.trim().isEmpty) {

      return 'This field is required';
    }

    return null;
  }


  String? _emailValidator(
    String? value,
  ) {

    final email =
        value?.trim() ?? '';


    if (email.isEmpty) {
      return 'Please enter your email';
    }


    final validEmail =
        RegExp(
          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
        ).hasMatch(email);


    if (!validEmail) {
      return 'Please enter a valid email';
    }


    return null;
  }


  String? _mobileValidator(
    String? value,
  ) {

    final mobile =
        value?.trim() ?? '';


    if (mobile.isEmpty) {
      return 'Please enter your contact number';
    }


    final digits =
        mobile.replaceAll(
          RegExp(r'\D'),
          '',
        );


    if (digits.length < 10) {
      return 'Please enter a valid contact number';
    }


    return null;
  }


  String? _pincodeValidator(
    String? value,
  ) {

    final pincode =
        value?.trim() ?? '';


    if (pincode.isEmpty) {
      return 'Please enter your PIN code';
    }


    if (pincode.length < 4) {
      return 'Please enter a valid PIN code';
    }


    return null;
  }


  String? _passwordValidator(
    String? value,
  ) {

    if (value == null ||
        value.isEmpty) {

      return 'Please enter a password';
    }


    if (value.length < 8) {

      return
          'Password must contain at least 8 characters';
    }


    return null;
  }


  String? _websiteValidator(
    String? value,
  ) {

    final website =
        value?.trim() ?? '';


    // Website is optional.
    if (website.isEmpty) {
      return null;
    }


    final validWebsite =
        RegExp(
          r'^(https?://)?'
          r'([\w-]+\.)+[\w-]+'
          r'(/[^\s]*)?$',
        ).hasMatch(website);


    if (!validWebsite) {
      return 'Please enter a valid website';
    }


    return null;
  }
}

