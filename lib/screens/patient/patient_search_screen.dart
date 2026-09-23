import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import 'package:docautomations/datamodels/master/patient.dart';
import 'package:docautomations/repositories/patient_repository.dart';


//=============================================================================
// PATIENT SEARCH SCREEN
//=============================================================================
//
// Responsibilities:
//
//   • Search for an existing patient.
//   • Search using PPID.
//   • Scan PPID QR code.
//   • Display the found patient.
//   • Start New Patient registration.
//   • Allow the doctor to logout.
//
// This screen does NOT:
//
//   • call Dio directly.
//   • call PatientApiService directly.
//   • access SharedPreferences.
//   • access secure storage.
//   • call AuthService directly.
//   • create prescriptions.
//   • contain prescription workflow logic.
//   • contain legacy LicenseProvider logic.
//   • use the old Addprescrip screen.
//
// Flow:
//
//   PatientSearchScreen
//          ↓
//   PatientRepository
//          ↓
//   PatientApiService
//          ↓
//   Backend
//
// Existing patient:
//
//   Search PPID / Scan QR
//          ↓
//   Patient
//          ↓
//   onPatientSelected
//
// New patient:
//
//   New Patient
//          ↓
//   onNewPatientRequested
//
// Logout:
//
//   Logout
//          ↓
//   onLogout not required hanndled from menu 
//
//=============================================================================

class PatientSearchScreen extends StatefulWidget {

  const PatientSearchScreen({
    super.key,
    required this.onPatientSelected,
    required this.onNewPatientRequested,
    
  });


  //-------------------------------------------------------------------------
  // CALLBACKS
  //-------------------------------------------------------------------------

  /// Called when an existing patient has been successfully found.
  final ValueChanged<Patient> onPatientSelected;


  /// Called when the doctor wants to register a new patient.
  final VoidCallback onNewPatientRequested;


  


  @override
  State<PatientSearchScreen> createState() =>
      _PatientSearchScreenState();
}


//=============================================================================
// PATIENT SEARCH SCREEN STATE
//=============================================================================

class _PatientSearchScreenState
    extends State<PatientSearchScreen> {

  //-------------------------------------------------------------------------
  // CONTROLLERS
  //-------------------------------------------------------------------------

  final TextEditingController _ppidController =
      TextEditingController();


  //-------------------------------------------------------------------------
  // STATE
  //-------------------------------------------------------------------------

  bool _isSearching = false;

  String? _errorMessage;

  Patient? _foundPatient;


  //-------------------------------------------------------------------------
  // LIFECYCLE
  //-------------------------------------------------------------------------

  @override
  void dispose() {

    _ppidController.dispose();

    super.dispose();
  }


  //-------------------------------------------------------------------------
  // SEARCH PATIENT
  //-------------------------------------------------------------------------

  Future<void> _searchPatient() async {

    final ppid =
        _ppidController.text.trim();


    //-------------------------------------------------------------------------
    // Validate PPID
    //-------------------------------------------------------------------------

    if (ppid.isEmpty) {

      setState(() {

        _errorMessage =
            'Please enter the patient PPID.';

        _foundPatient =
            null;
      });

      return;
    }


    FocusScope.of(context).unfocus();


    setState(() {

      _isSearching =
          true;

      _errorMessage =
          null;

      _foundPatient =
          null;
    });


    try {

      final repository =
          context.read<PatientRepository>();


      //=======================================================================
      // Search patient
      //=======================================================================

      final result =
          await repository.getPatient(
        ppid,
      );


      if (!mounted) {
        return;
      }


      if (!result.success) {

        setState(() {

          _errorMessage =
              result.message.isNotEmpty
                  ? result.message
                  : 'Patient not found.';
        });

        return;
      }


      //=======================================================================
      // Extract patient
      //=======================================================================

      final patient =
          _extractPatient(result.data);


      if (patient == null) {

        setState(() {

          _errorMessage =
              'Patient information could not be read.';
        });

        return;
      }


      //=======================================================================
      // Patient found
      //=======================================================================

      setState(() {

        _foundPatient =
            patient;

        _errorMessage =
            null;
      });


    } catch (e) {

      if (!mounted) {
        return;
      }


      setState(() {

        _errorMessage =
            'Unable to search for the patient.';
      });

    } finally {

      if (mounted) {

        setState(() {

          _isSearching =
              false;
        });
      }
    }
  }


  //-------------------------------------------------------------------------
  // EXTRACT PATIENT
  //-------------------------------------------------------------------------
  //
  // PatientRepository may return:
  //
  //   • Patient
  //   • Map containing patient data
  //
  // Keep this conversion in the UI boundary so the rest of the screen works
  // with a strongly typed Patient object.
  //
  //-------------------------------------------------------------------------

  Patient? _extractPatient(
    dynamic data,
  ) {

    if (data is Patient) {
      return data;
    }


    if (data is Map<String, dynamic>) {

      //=======================================================================
      // Direct patient object
      //=======================================================================

      final patientData =
          data['patient'];


      if (patientData is Map<String, dynamic>) {

        return Patient.fromJson(
          patientData,
        );
      }


      //=======================================================================
      // Data itself is patient JSON
      //=======================================================================

      try {

        return Patient.fromJson(
          data,
        );

      } catch (_) {

        return null;
      }
    }


    return null;
  }


  //-------------------------------------------------------------------------
  // QR SCANNER
  //-------------------------------------------------------------------------

  Future<void> _scanQRCode() async {

    FocusScope.of(context).unfocus();


    final ppid =
        await Navigator.of(context).push<String>(

      MaterialPageRoute(
        builder: (_) =>
            const _PpidQrScannerScreen(),
      ),
    );


    if (!mounted ||
        ppid == null ||
        ppid.trim().isEmpty) {

      return;
    }


    _ppidController.text =
        ppid.trim();


    await _searchPatient();
  }


  //-------------------------------------------------------------------------
  // NEW PATIENT
  //-------------------------------------------------------------------------

  void _newPatient() {

    if (_isSearching) {
      return;
    }


    widget.onNewPatientRequested();
  }


  //-------------------------------------------------------------------------
  // SELECT FOUND PATIENT
  //-------------------------------------------------------------------------

  void _selectPatient() {

    final patient =
        _foundPatient;


    if (patient == null) {
      return;
    }


    widget.onPatientSelected(
      patient,
    );
  }


  //-------------------------------------------------------------------------
  // LOGOUT
  //-------------------------------------------------------------------------

  Future<void> _logout() async {

    if (_isSearching) {
      return;
    }


    final shouldLogout =
        await _showLogoutConfirmation();


    if (!shouldLogout ||
        !mounted) {

      return;
    }


   
  }


  //-------------------------------------------------------------------------
  // LOGOUT CONFIRMATION
  //-------------------------------------------------------------------------

  Future<bool> _showLogoutConfirmation() async {

    final result =
        await showDialog<bool>(

      context: context,

      builder: (context) {

        return AlertDialog(

          title:
              const Text(
            'Logout',
          ),

          content:
              const Text(
            'Are you sure you want to logout?',
          ),

          actions: [

            TextButton(

              onPressed:
                  () => Navigator.of(context)
                      .pop(false),

              child:
                  const Text(
                'Cancel',
              ),
            ),


            FilledButton(

              onPressed:
                  () => Navigator.of(context)
                      .pop(true),

              child:
                  const Text(
                'Logout',
              ),
            ),
          ],
        );
      },
    );


    return result ?? false;
  }


  //-------------------------------------------------------------------------
  // BUILD
  //-------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {

    final theme =
        Theme.of(context);


    return Scaffold(

      appBar:
          AppBar(

        title:
            const Text(
          'Patients',
        ),


        actions: [

          IconButton(

            tooltip:
                'Logout',

            onPressed:
                _isSearching
                    ? null
                    : _logout,

            icon:
                const Icon(
              Icons.logout_rounded,
            ),
          ),
        ],
      ),


      body:
          SafeArea(

        child:
            SingleChildScrollView(

          padding:
              const EdgeInsets.fromLTRB(
            24,
            24,
            24,
            40,
          ),


          child:
              Center(

            child:
                ConstrainedBox(

              constraints:
                  const BoxConstraints(
                maxWidth: 600,
              ),


              child:
                  Column(

                crossAxisAlignment:
                    CrossAxisAlignment.stretch,

                children: [

                  //===========================================================
                  // HEADER
                  //===========================================================

                  _buildHeader(theme),


                  const SizedBox(
                    height: 32,
                  ),


                  //===========================================================
                  // SEARCH CARD
                  //===========================================================

                  _buildSearchCard(
                    theme,
                  ),


                  const SizedBox(
                    height: 24,
                  ),


                  //===========================================================
                  // ERROR
                  //===========================================================

                  if (_errorMessage != null)
                    _buildErrorMessage(
                      theme,
                    ),


                  if (_errorMessage != null)
                    const SizedBox(
                      height: 20,
                    ),


                  //===========================================================
                  // FOUND PATIENT
                  //===========================================================

                  if (_foundPatient != null)
                    _buildPatientCard(
                      theme,
                      _foundPatient!,
                    ),


                  if (_foundPatient != null)
                    const SizedBox(
                      height: 24,
                    ),


                  //===========================================================
                  // NEW PATIENT
                  //===========================================================

                  _buildNewPatientCard(
                    theme,
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
  // HEADER
  //-------------------------------------------------------------------------

  Widget _buildHeader(
    ThemeData theme,
  ) {

    return Column(

      children: [

        Container(

          width:
              76,

          height:
              76,

          decoration:
              BoxDecoration(

            color:
                theme.colorScheme.primaryContainer,

            shape:
                BoxShape.circle,
          ),


          child:
              Icon(

            Icons.people_alt_rounded,

            size:
                40,

            color:
                theme.colorScheme.onPrimaryContainer,
          ),
        ),


        const SizedBox(
          height: 18,
        ),


        Text(

          'Find Patient',

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

          'Search using the patient PPID or scan the patient QR code.',

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
  // SEARCH CARD
  //-------------------------------------------------------------------------

  Widget _buildSearchCard(
    ThemeData theme,
  ) {

    return Card(

      elevation:
          0,

      child:
          Padding(

        padding:
            const EdgeInsets.all(20),

        child:
            Column(

          crossAxisAlignment:
              CrossAxisAlignment.stretch,

          children: [

            Text(

              'Search Existing Patient',

              style:
                  theme.textTheme.titleMedium?.copyWith(

                fontWeight:
                    FontWeight.w800,
              ),
            ),


            const SizedBox(
              height: 16,
            ),


            TextFormField(

              controller:
                  _ppidController,

              enabled:
                  !_isSearching,

              textCapitalization:
                  TextCapitalization.characters,

              autocorrect:
                  false,

              onFieldSubmitted:
                  (_) => _searchPatient(),

              decoration:
                  InputDecoration(

                labelText:
                    'Patient PPID',

                hintText:
                    'Enter patient PPID',

                prefixIcon:
                    const Icon(
                  Icons.badge_outlined,
                ),

                suffixIcon:
                    IconButton(

                  tooltip:
                      'Scan QR Code',

                  onPressed:
                      _isSearching
                          ? null
                          : _scanQRCode,

                  icon:
                      const Icon(
                    Icons.qr_code_scanner_rounded,
                  ),
                ),
              ),
            ),


            const SizedBox(
              height: 16,
            ),


            SizedBox(

              height:
                  50,

              child:
                  FilledButton.icon(

                onPressed:
                    _isSearching
                        ? null
                        : _searchPatient,

                icon:
                    _isSearching

                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2.5,
                            ),
                          )

                        : const Icon(
                            Icons.search_rounded,
                          ),

                label:
                    Text(
                  _isSearching
                      ? 'Searching...'
                      : 'Search Patient',

                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  //-------------------------------------------------------------------------
  // PATIENT CARD
  //-------------------------------------------------------------------------

  Widget _buildPatientCard(
    ThemeData theme,
    Patient patient,
  ) {

    return Card(

      elevation:
          0,

      child:
          Padding(

        padding:
            const EdgeInsets.all(20),

        child:
            Column(

          crossAxisAlignment:
              CrossAxisAlignment.stretch,

          children: [

            Row(

              children: [

                Container(

                  width:
                      52,

                  height:
                      52,

                  decoration:
                      BoxDecoration(

                    color:
                        theme.colorScheme.secondaryContainer,

                    shape:
                        BoxShape.circle,
                  ),

                  child:
                      Icon(

                    Icons.person_rounded,

                    color:
                        theme.colorScheme
                            .onSecondaryContainer,
                  ),
                ),


                const SizedBox(
                  width: 14,
                ),


                Expanded(

                  child:
                      Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(

                        _patientName(patient),

                        maxLines:
                            2,

                        overflow:
                            TextOverflow.ellipsis,

                        style:
                            theme.textTheme.titleMedium?.copyWith(

                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),


                      const SizedBox(
                        height: 4,
                      ),


                      Text(

                        patient.ppid,

                        style:
                            theme.textTheme.bodyMedium?.copyWith(

                          color:
                              theme.colorScheme
                                  .primary,

                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),


            const SizedBox(
              height: 20,
            ),


            const Divider(),


            const SizedBox(
              height: 12,
            ),


            _buildPatientDetail(
              icon:
                  Icons.calendar_today_outlined,

              label:
                  'Date of Birth',

              value:
                  _formatDate(
                patient.dob,
              ),
            ),


            const SizedBox(
              height: 10,
            ),


            _buildPatientDetail(
              icon:
                  Icons.person_outline_rounded,

              label:
                  'Gender',

              value:
                  patient.gender,
            ),


            if (_hasValue(patient.mobile)) ...[

              const SizedBox(
                height: 10,
              ),

              _buildPatientDetail(
                icon:
                    Icons.phone_outlined,

                label:
                    'Mobile',

                value:
                    patient.mobile,
              ),
            ],


            const SizedBox(
              height: 20,
            ),


            SizedBox(

              height:
                  48,

              child:
                  FilledButton.icon(

                onPressed:
                    _selectPatient,

                icon:
                    const Icon(
                  Icons.arrow_forward_rounded,
                ),

                label:
                    const Text(
                  'Continue with Patient',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  //-------------------------------------------------------------------------
  // PATIENT DETAIL
  //-------------------------------------------------------------------------

  Widget _buildPatientDetail({
    required IconData icon,
    required String label,
    required String value,
  }) {

    return Row(

      children: [

        Icon(
          icon,
          size: 20,
        ),


        const SizedBox(
          width: 12,
        ),


        Text(
          '$label: ',
          style:
              const TextStyle(
            fontWeight:
                FontWeight.w600,
          ),
        ),


        Expanded(

          child:
              Text(
            value,
          ),
        ),
      ],
    );
  }


  //-------------------------------------------------------------------------
  // NEW PATIENT CARD
  //-------------------------------------------------------------------------

  Widget _buildNewPatientCard(
    ThemeData theme,
  ) {

    return Card(

      elevation:
          0,

      child:
          Padding(

        padding:
            const EdgeInsets.all(20),

        child:
            Column(

          children: [

            Icon(

              Icons.person_add_alt_1_rounded,

              size:
                  38,

              color:
                  theme.colorScheme.primary,
            ),


            const SizedBox(
              height: 12,
            ),


            Text(

              'New Patient?',

              style:
                  theme.textTheme.titleMedium?.copyWith(

                fontWeight:
                    FontWeight.w800,
              ),
            ),


            const SizedBox(
              height: 6,
            ),


            Text(

              'Register a new patient and start a consultation.',

              textAlign:
                  TextAlign.center,

              style:
                  theme.textTheme.bodyMedium?.copyWith(

                color:
                    theme.colorScheme.onSurfaceVariant,
              ),
            ),


            const SizedBox(
              height: 16,
            ),


            OutlinedButton.icon(

              onPressed:
                  _isSearching
                      ? null
                      : _newPatient,

              icon:
                  const Icon(
                Icons.person_add_alt_1_rounded,
              ),

              label:
                  const Text(
                'Register New Patient',
              ),
            ),
          ],
        ),
      ),
    );
  }


  //-------------------------------------------------------------------------
  // ERROR MESSAGE
  //-------------------------------------------------------------------------

  Widget _buildErrorMessage(
    ThemeData theme,
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

              _errorMessage!,

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
  // PATIENT NAME
  //-------------------------------------------------------------------------

  String _patientName(
    Patient patient,
  ) {

    final parts =
        <String>[

      patient.firstName,

      if (patient.middleName.trim().isNotEmpty)
        patient.middleName,

      patient.lastName,
    ];


    return parts
        .where(
          (value) => value.trim().isNotEmpty,
        )
        .join(' ');
  }


  //-------------------------------------------------------------------------
  // DATE FORMAT
  //-------------------------------------------------------------------------

  String _formatDate(
    DateTime? date,
  ) {
if (date == null) { return 'Not available'; }
    final day =
        date.day.toString().padLeft(
          2,
          '0',
        );

    final month =
        date.month.toString().padLeft(
          2,
          '0',
        );

    return '$day/$month/${date.year}';
  }


  //-------------------------------------------------------------------------
  // VALUE CHECK
  //-------------------------------------------------------------------------

  bool _hasValue(
    String? value,
  ) {

    return value != null &&
        value.trim().isNotEmpty;
  }
}


//=============================================================================
// PPID QR SCANNER
//=============================================================================
//
// This is deliberately kept private to the PatientSearchScreen.
//
// The scanner only has one responsibility:
//
//   Scan QR → return the scanned PPID.
//
// It does not search the backend itself.
//
//=============================================================================

class _PpidQrScannerScreen
    extends StatefulWidget {

  const _PpidQrScannerScreen();


  @override
  State<_PpidQrScannerScreen> createState() =>
      _PpidQrScannerScreenState();
}


//=============================================================================
// PPID QR SCANNER STATE
//=============================================================================

class _PpidQrScannerScreenState
    extends State<_PpidQrScannerScreen> {

  final MobileScannerController _scannerController =
      MobileScannerController();


  bool _hasScanned = false;


  @override
  void dispose() {

    _scannerController.dispose();

    super.dispose();
  }


  //-------------------------------------------------------------------------
  // HANDLE SCAN
  //-------------------------------------------------------------------------

  void _handleBarcode(
    BarcodeCapture capture,
  ) {

    if (_hasScanned) {
      return;
    }


    for (final barcode in capture.barcodes) {

      final value =
          barcode.rawValue?.trim();


      if (value == null ||
          value.isEmpty) {

        continue;
      }


      _hasScanned = true;


      _scannerController.stop();


      Navigator.of(context).pop(
        value,
      );


      return;
    }
  }


  //-------------------------------------------------------------------------
  // BUILD
  //-------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {

    final theme =
        Theme.of(context);


    return Scaffold(

      appBar:
          AppBar(

        title:
            const Text(
          'Scan Patient QR Code',
        ),
      ),


      body:
          Stack(

        fit:
            StackFit.expand,

        children: [

          MobileScanner(

            controller:
                _scannerController,

            onDetect:
                _handleBarcode,
          ),


          //===================================================================
          // SCANNER OVERLAY
          //===================================================================

          Center(

            child:
                Container(

              width:
                  270,

              height:
                  180,

              decoration:
                  BoxDecoration(

                border:
                    Border.all(
                  color:
                      theme.colorScheme.primary,
                  width:
                      3,
                ),

                borderRadius:
                    BorderRadius.circular(16),
              ),
            ),
          ),


          //===================================================================
          // INSTRUCTION
          //===================================================================

          Positioned(

            left:
                24,

            right:
                24,

            bottom:
                48,

            child:
                Container(

              padding:
                  const EdgeInsets.all(16),

              decoration:
                  BoxDecoration(

                color:
                    Colors.black.withValues(
                  alpha: 0.70,
                ),

                borderRadius:
                    BorderRadius.circular(14),
              ),


              child:
                  const Text(

                'Place the patient QR code inside the frame.',

                textAlign:
                    TextAlign.center,

                style:
                    TextStyle(
                  color:
                      Colors.white,

                  fontSize:
                      15,

                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

