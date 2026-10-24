import 'package:docautomations/commonwidget/ppid_qr_scanner_screen.dart';
import 'package:docautomations/datamodels/master/patient_search_result.dart';
import 'package:docautomations/repositories/patient_repository.dart';
import 'package:docautomations/repositories/prescription_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:docautomations/controllers/add_prescription_controller.dart';
import 'package:docautomations/datamodels/master/patient.dart';

import 'package:docautomations/datamodels/master/patient_doctor.dart';
import 'package:docautomations/datamodels/master/patient_mode.dart';



import 'package:docautomations/screens/prescription/add_prescription.dart';
import  'package:docautomations/datamodels/prescriptionData.dart';
import 'package:docautomations/datamodels/master/master_data.dart';


import 'dart:typed_data';

import 'package:docautomations/datamodels/snapshot/prescription_snapshot.dart';
import 'package:docautomations/device_assets/asset_manager.dart';
import 'package:docautomations/services/prescription_pdf_service.dart';
import 'package:docautomations/widgets/print_preview_screen.dart';


class PatientPrescriptionScreen extends StatefulWidget {

  final PatientMode mode;

  final Patient? patient;

  final PatientDoctor? patientDoctor;

  final Map<String, dynamic>? prescription;

  final MasterData masterData;


  


  const PatientPrescriptionScreen({
  super.key,
  required this.mode,
  this.patient,
  this.patientDoctor,
   this.prescription,
  required this.masterData,
  });


  @override
  State<PatientPrescriptionScreen> createState() =>
      _PatientPrescriptionScreenState();

}


class _PatientPrescriptionScreenState
    extends State<PatientPrescriptionScreen> {

  late final AddPrescriptionController controller;

  late final PrescriptionPdfService pdfService;


  bool _initialized = false;

  String? _selectedBloodGroup;

  static const List<String> _bloodGroups = [
  "A+",
  "A-",
  "B+",
  "B-",
  "AB+",
  "AB-",
  "O+",
  "O-",
];
  //-------------------------------------------------------------------------
  // Controllers for NEW patient master data
  //-------------------------------------------------------------------------

  final _firstNameController =
      TextEditingController();

  final _middleNameController =
      TextEditingController();

  final _lastNameController =
      TextEditingController();

  final _dobController =
      TextEditingController();

  final _mobileController =
      TextEditingController();

  final _loginEmailController =
      TextEditingController();

  final _address1Controller =
      TextEditingController();

  final _guardianPPIDController =
    TextEditingController();

  final _address2Controller =
      TextEditingController();

  final _cityController =
      TextEditingController();

  final _stateController =
      TextEditingController();

  final _pinCodeController =
      TextEditingController();


  //-------------------------------------------------------------------------
  // Consultation controllers
  //-------------------------------------------------------------------------

  final _chiefComplaintController =
      TextEditingController();

  final _examinationController =
      TextEditingController();

  final _diagnosisController =
      TextEditingController();

  final _adviceController =
      TextEditingController();

  final _remarksController =
      TextEditingController();

  final _followUpDateController =
      TextEditingController();

      final _heightFeetController =
    TextEditingController();

final _heightInchesController =
    TextEditingController();

final _weightController =
    TextEditingController();

final _systolicBPController =
    TextEditingController();

final _diastolicBPController =
    TextEditingController();


  String _gender = "Male";

  DateTime? _dob;

  DateTime? _followUpDate;

  // Selected country from MasterData
  String? _selectedCountryId;


 @override
void initState() {
  super.initState();

  final masterData =
      widget.masterData;

 controller = AddPrescriptionController(
  mode: widget.mode,
  patient: widget.patient,
  patientDoctor: widget.patientDoctor,
  existingPrescription: widget.prescription,
  prescriptionRepository://prescriptionRepository,
      context.read<PrescriptionRepository>(),
  masterData:
      widget.masterData,
);

  pdfService =
      PrescriptionPdfService(
        assetManager:
            context.read<AssetManager>(),
      );
}


void _initializeDefaultCountry() {
  if (_selectedCountryId != null &&
      _selectedCountryId!.isNotEmpty) {
    return;
  }

  for (final country in widget.masterData.countries) {
    if (country.countryName.toLowerCase() == "india") {
      _selectedCountryId = country.id;
      return;
    }
  }
}

Future<void> _loadGuardianDetails(
  String guardianPPID,
) async {

  final ppid =
      guardianPPID.trim().toUpperCase();

  if (ppid.isEmpty) {
    return;
  }

  try {

    final repository =
        context.read<PatientRepository>();

    final result =
        await repository.findPatientByPpid(
      ppid,
    );

    if (!mounted) {
      return;
    }

    if (!result.success) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            result.message.isNotEmpty
                ? result.message
                : "Guardian not found.",
          ),
        ),
      );

      return;
    }

    if (result.data
        is! PatientSearchResult) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Invalid guardian information received.",
          ),
        ),
      );

      return;
    }

    final searchResult =
        result.data as PatientSearchResult;

    final guardian =
        searchResult.patient;

    if (guardian == null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Guardian not found.",
          ),
        ),
      );

      return;
    }

    _populateFromGuardian(
      guardian,
    );

  } catch (error) {

    debugPrint(
      "GUARDIAN PPID LOOKUP ERROR: $error",
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Unable to retrieve guardian information.",
        ),
      ),
    );
  }
}


void _populateFromGuardian(
  Patient guardian,
) {

  setState(() {

    _mobileController.text =
        guardian.mobile;

    _loginEmailController.text =
        guardian.loginEmail;

    _address1Controller.text =
        guardian.addressLine1;

    _address2Controller.text =
        guardian.addressLine2;

    _cityController.text =
        guardian.city;

    _stateController.text =
        guardian.state;

    _pinCodeController.text =
        guardian.pinCode;

    _selectedCountryId =
        guardian.countryId;
  });
}

  @override
  void didChangeDependencies() {

    super.didChangeDependencies();

    if (_initialized) {
      return;
    }

    _initialized = true;

    _initialize();

  }


  Future<void> _initialize() async {

    try {

      await controller.initialize();

      if (!mounted) {
        return;
      }

      _populateScreenFromController();

      if (widget.mode == PatientMode.newPatient &&
    (_selectedCountryId == null ||
        _selectedCountryId!.isEmpty)) {
  _initializeDefaultCountry();
}

      setState(() {});

    }
    catch (error) {

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Unable to initialize prescription: $error",
          ),
        ),
      );

    }

  }


  //-------------------------------------------------------------------------
  // Populate UI
  //-------------------------------------------------------------------------

  void _populateScreenFromController() {

    final patient =
        controller.currentPatient;


    if (patient != null) {

      _firstNameController.text =
          patient.firstName;

      _middleNameController.text =
          patient.middleName;

      _lastNameController.text =
          patient.lastName;

      _guardianPPIDController.text =
          patient.guardianPPID ?? "";

      _mobileController.text =
          patient.mobile;

      _loginEmailController.text =
          patient.loginEmail;

      _address1Controller.text =
          patient.addressLine1;

      _address2Controller.text =
          patient.addressLine2;

      _cityController.text =
          patient.city;

      _stateController.text =
          patient.state;

      _pinCodeController.text =
          patient.pinCode;

      _gender =
          patient.gender;

      _dob =
          patient.dob;

      if (_dob != null) {

        _dobController.text =
            _formatDate(_dob!);

      }

      _selectedCountryId =
    patient.countryId;

    }


    final prescription =
        controller.prescription;


    _chiefComplaintController.text =
        prescription.chiefComplaint;

    _examinationController.text =
        prescription.examination;

    _diagnosisController.text =
        prescription.diagnosis;

    _adviceController.text =
        prescription.advice;

    _remarksController.text =
        prescription.remarks;


    _followUpDate =
        prescription.followUpDate;


    if (_followUpDate != null) {

      _followUpDateController.text =
          _formatDate(_followUpDate!);

    }

  }


  String _formatDate(DateTime date) {

    return
        "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";

  }


  //-------------------------------------------------------------------------
  // Dispose
  //-------------------------------------------------------------------------

  @override
  void dispose() {

    controller.dispose();

    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _mobileController.dispose();
    _loginEmailController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pinCodeController.dispose();
    _guardianPPIDController.dispose();
    _chiefComplaintController.dispose();
    _examinationController.dispose();
    _diagnosisController.dispose();
    _adviceController.dispose();
    _remarksController.dispose();
    _followUpDateController.dispose();
    _heightFeetController.dispose();
_heightInchesController.dispose();
_weightController.dispose();
_systolicBPController.dispose();
_diastolicBPController.dispose();

    super.dispose();

  }


  //-------------------------------------------------------------------------
  // Build
  //-------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider.value(

      value:
          controller,

      child:
          Consumer<AddPrescriptionController>(

        builder:
            (
              context,
              controller,
              child,
            ) {

          if (controller.isLoading) {

            return const Scaffold(

              body:
                  Center(
                child:
                    CircularProgressIndicator(),
              ),

            );

          }


          return Scaffold(

            appBar:
                AppBar(

              title:
                  Text(
                widget.mode ==
                        PatientMode.newPatient
                    ? "New Prescription"
                    : "Patient Prescription",
              ),

            ),


            body:
                SafeArea(

              child:
                  SingleChildScrollView(

                padding:
                    const EdgeInsets.all(16),

                child:
                    Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,

                  children: [

                    _buildPatientSection(),

                    const SizedBox(height: 16),

                    _buildConsultationSection(),

                    const SizedBox(height: 16),

                    _buildMedicineSection(),

                    const SizedBox(height: 24),

                    _buildGenerateButton(),

                  ],

                ),

              ),

            ),

          );

        },

      ),

    );

  }


  //-------------------------------------------------------------------------
  // Patient Section
  //-------------------------------------------------------------------------

  Widget _buildPatientSection() {

    final isNew =
        widget.mode ==
            PatientMode.newPatient;


    return Card(

      child:
          Padding(

        padding:
            const EdgeInsets.all(16),

        child:
            Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(

              isNew
                  ? "Patient Details"
                  : "Patient",

              style:
                  Theme.of(context)
                      .textTheme
                      .titleLarge,

            ),

            const SizedBox(height: 16),


            if (!isNew)
              _buildExistingPatientHeader()
            else
              _buildNewPatientForm(),

          ],

        ),

      ),

    );

  }


  //-------------------------------------------------------------------------
  // Existing patient
  //-------------------------------------------------------------------------

  Widget _buildExistingPatientHeader() {

    final patient =
        controller.currentPatient;


    if (patient == null) {

      return const Text(
        "Patient information unavailable.",
      );

    }


    return Column(

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Row(

          children: [

            Expanded(

              child:
                  Text(
                patient.fullName,

                style:
                    Theme.of(context)
                        .textTheme
                        .titleMedium,
              ),

            ),

            Chip(
              label:
                  Text(
                 'PPID: ${patient.ppid}',
              ),
            ),

          ],

        ),

        const SizedBox(height: 12),

        _patientInfoRow(
          "DOB",
          patient.dob == null
              ? "-"
              : _formatDate(patient.dob!),
        ),

        _patientInfoRow(
          "Gender",
          patient.gender,
        ),

        _patientInfoRow(
          "Mobile",
          patient.mobile,
        ),

        _patientInfoRow(
          "Address",
          [
            patient.addressLine1,
            patient.addressLine2,
            patient.city,
            patient.state,
            patient.pinCode,
          ]
              .where(
                (value) =>
                    value.trim().isNotEmpty,
              )
              .join(", "),
        ),

      ],

    );

  }


  Widget _patientInfoRow(
    String label,
    String value,
  ) {

    return Padding(

      padding:
          const EdgeInsets.only(
        bottom: 6,
      ),

      child:
          Row(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          SizedBox(

            width: 90,

            child:
                Text(
              label,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),

          ),

          Expanded(
            child:
                Text(
              value.isEmpty
                  ? "-"
                  : value,
            ),
          ),

        ],

      ),

    );

  }


Future<void> _scanGuardianPPID() async {

  FocusScope.of(context).unfocus();

  final scannedPPID =
      await Navigator.of(context)
          .push<String>(
    MaterialPageRoute(
      builder: (_) =>
          const PpidQrScannerScreen(),
    ),
  );

  if (!mounted) {
    return;
  }

  if (scannedPPID == null ||
      scannedPPID.trim().isEmpty) {
    return;
  }

  final ppid =
      scannedPPID.trim().toUpperCase();

  setState(() {

    _guardianPPIDController.text =
        ppid;
  });

  await _loadGuardianDetails(
    ppid,
  );
}

  //-------------------------------------------------------------------------
  // New Patient Form
  //-------------------------------------------------------------------------

  Widget _buildNewPatientForm() {

    return Column(

      children: [

        Row(

          children: [

            Expanded(
              child:
                  _textField(
                "First Name",
                _firstNameController,
                required: true,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child:
                  _textField(
                "Middle Name",
                _middleNameController,
              ),
            ),

          ],

        ),

        _textField(
          "Last Name",
          _lastNameController,
          required: true,
        ),


        //Guardian PPID

const SizedBox(height: 12),

TextFormField(
  controller:
      _guardianPPIDController,

  enabled:
      !controller.isLoading,

  textCapitalization:
      TextCapitalization.characters,

  autocorrect: false,

  onFieldSubmitted: (value) async {
    await _loadGuardianDetails(value);
  },

  decoration: InputDecoration(
    labelText:
        "Guardian / Head of Family PPID",

    hintText:
        "Enter or scan PPID",

    helperText:
        "Optional. Guardian contact and address can be used for the patient.",

    prefixIcon: const Icon(
      Icons.family_restroom,
    ),

    suffixIcon: IconButton(
      tooltip:
          "Scan Guardian PPID",

      icon: const Icon(
        Icons.qr_code_scanner_rounded,
      ),

      onPressed:
          controller.isLoading
              ? null
              : _scanGuardianPPID,
    ),

    border:
        const OutlineInputBorder(),
  ),
),
        Row(

          children: [

            Expanded(
              child:
                  _dateField(
                "Date of Birth",
                _dobController,
                onTap: _selectDob,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child:
                  DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration:
                    const InputDecoration(
                  labelText: "Gender",
                  border:
                      OutlineInputBorder(),
                ),
                items:
                    const [
                  DropdownMenuItem(
                    value: "Male",
                    child: Text("Male"),
                  ),
                  DropdownMenuItem(
                    value: "Female",
                    child: Text("Female"),
                  ),
                  DropdownMenuItem(
                    value: "Other",
                    child: Text("Other"),
                  ),
                ],
                onChanged:
                    (value) {

                  if (value != null) {

                    setState(() {
                      _gender = value;
                    });

                  }

                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child:
                  DropdownButtonFormField<String>(
                initialValue:
                    _selectedBloodGroup,
                decoration:
                    const InputDecoration(
                  labelText: "Blood Group",
                  border:
                      OutlineInputBorder(),
                ),
                items: _bloodGroups
                    .map(
                      (bg) =>
                          DropdownMenuItem(
                        value: bg,
                        child: Text(bg),
                      ),
                    )
                    .toList(),
                onChanged:
                    (value) {

                  setState(() {
                    _selectedBloodGroup =
                        value;
                  });

                },
              ),
            ),
        
          ],

        ),

        const SizedBox(height: 12),

        _textField(
          "Mobile",
          _mobileController,
          keyboardType:
              TextInputType.phone,
        ),

        _textField(
          "Email",
          _loginEmailController,
          keyboardType:
              TextInputType.emailAddress,
        ),

        _textField(
          "Address Line 1",
          _address1Controller,
        ),

        _textField(
          "Address Line 2",
          _address2Controller,
        ),

        Row(

          children: [

            Expanded(
              child:
                  _textField(
                "City",
                _cityController,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child:
                  _textField(
                "State",
                _stateController,
              ),
            ),

          ],

        ),
const SizedBox(height: 0),

// Country
DropdownButtonFormField<String>(
  initialValue: _selectedCountryId,

  isExpanded: true,

  decoration: const InputDecoration(
    labelText: "Country *",
    border: OutlineInputBorder(),
  ),

  items: widget.masterData.countries
      .map(
        (country) => DropdownMenuItem<String>(
          value: country.id,

          child: Text(
            country.countryName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      )
      .toList(),

  onChanged: controller.isLoading
      ? null
      : (value) {
          setState(() {
            _selectedCountryId = value;
          });
        },
),

const SizedBox(height: 12),
        _textField(
          "PIN Code",
          _pinCodeController,
          keyboardType:
              TextInputType.number,
        ),

      ],

    );

  }


  //-------------------------------------------------------------------------
  // Consultation
  //-------------------------------------------------------------------------

  Widget _buildConsultationSection() {

    return Card(

      child:
          Padding(

        padding:
            const EdgeInsets.all(16),

        child:
            Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(

              "Consultation",

              style:
                  Theme.of(context)
                      .textTheme
                      .titleLarge,

            ),

           const SizedBox(height: 12),

Row(
  children: [
    Expanded(
      child: _textField(
        "Height (ft)",
        _heightFeetController,
        keyboardType: TextInputType.number,
      ),
    ),

    const SizedBox(width: 12),

    Expanded(
      child: _textField(
        "Height (in)",
        _heightInchesController,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
        ),
      ),
    ),

    const SizedBox(width: 12),

    Expanded(
      child: _textField(
        "Weight (kg)",
        _weightController,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
        ),
      ),
    ),
  ],
),

const SizedBox(height: 12),

Row(
  children: [
    Expanded(
      child: _textField(
        "Systolic BP",
        _systolicBPController,
        keyboardType: TextInputType.number,
      ),
    ),

    const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        "/",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    Expanded(
      child: _textField(
        "Diastolic BP",
        _diastolicBPController,
        keyboardType: TextInputType.number,
      ),
    ),
  ],
),

const SizedBox(height: 16),

            _textField(
              "Chief Complaint",
              _chiefComplaintController,
              maxLines: 3,
            ),

            _textField(
              "Examination",
              _examinationController,
              maxLines: 3,
            ),

            _textField(
              "Diagnosis",
              _diagnosisController,
              maxLines: 3,
            ),

            _textField(
              "Advice",
              _adviceController,
              maxLines: 3,
            ),

            _dateField(
              "Follow-up Date",
              _followUpDateController,
              onTap:
                  _selectFollowUpDate,
            ),

            _textField(
              "Remarks",
              _remarksController,
              maxLines: 3,
            ),

          ],

        ),

      ),

    );

  }


  //-------------------------------------------------------------------------
  // Medicines
  //-------------------------------------------------------------------------

  Widget _buildMedicineSection() {

    return Card(

      child:
          Padding(

        padding:
            const EdgeInsets.all(16),

        child:
            Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Row(

              children: [

                Expanded(

                  child:
                      Text(
                    "Medicines",

                    style:
                        Theme.of(context)
                            .textTheme
                            .titleLarge,
                  ),

                ),

                FilledButton.icon(

                  onPressed:
                      _addMedicine,

                  icon:
                      const Icon(
                    Icons.add,
                  ),

                  label:
                      const Text(
                    "Add Medicine",
                  ),

                ),

              ],

            ),

            const SizedBox(height: 12),


            if (controller.prescriptions.isEmpty)

              const Padding(

                padding:
                    EdgeInsets.symmetric(
                  vertical: 20,
                ),

                child:
                    Center(
                  child:
                      Text(
                    "No medicines added.",
                  ),
                ),

              )
            else

              ...controller.prescriptions
                  .asMap()
                  .entries
                  .map(
                    (entry) =>
                        _medicineTile(
                      entry.key,
                      entry.value,
                    ),
                  ),

          ],

        ),

      ),

    );

  }


  Widget _medicineTile(
    int index,
    Prescriptiondata medicine,
  ) {

    return Card(

      margin:
          const EdgeInsets.only(
        bottom: 8,
      ),

      child:
          ListTile(

        title:
            Text(
          medicine.drugName,
        ),

        subtitle:
            Text(
          medicine.remarks,
        ),

        trailing:
            Row(

          mainAxisSize:
              MainAxisSize.min,

          children: [

            IconButton(

              icon:
                  const Icon(
                Icons.edit,
              ),

              onPressed:
                  () =>
                      _editMedicine(
                index,
                medicine,
              ),

            ),

            IconButton(

              icon:
                  const Icon(
                Icons.delete,
              ),

              onPressed:
                  () =>
                      _deleteMedicine(
                index,
              ),

            ),

          ],

        ),

      ),

    );

  }


  //-------------------------------------------------------------------------
  // Add medicine
  //-------------------------------------------------------------------------

  Future<void> _addMedicine() async {

    final result =
        await Navigator.push(

      context,

      MaterialPageRoute(

        builder:
            (_) =>
                const AddPrescription(
          title:
              "Add Medicine",
        ),

      ),

    );


    if (result == null) {
      return;
    }


    controller.addMedicine(
      result,
    );

    setState(() {});

  }


  //-------------------------------------------------------------------------
  // Edit medicine
  //-------------------------------------------------------------------------

  Future<void> _editMedicine(
    int index,
    Prescriptiondata medicine,
  ) async {

    final result =
        await Navigator.push(

      context,

      MaterialPageRoute(

        builder:
            (_) =>
                AddPrescription(
          title:
              "Edit Medicine",
          existingPrescription:
              medicine,
        ),

      ),

    );


    if (result == null) {
      return;
    }


    controller.updateMedicine(
      index,
      result,
    );

    setState(() {});

  }


  //-------------------------------------------------------------------------
  // Delete medicine
  //-------------------------------------------------------------------------

  void _deleteMedicine(
    int index,
  ) {

    controller.deleteMedicine(
      index,
    );

    setState(() {});

  }


double? _getHeightCm() {
  final feetText =
      _heightFeetController.text.trim();

  final inchesText =
      _heightInchesController.text.trim();

  if (feetText.isEmpty &&
      inchesText.isEmpty) {
    return null;
  }

  final feet =
      double.tryParse(feetText) ?? 0;

  final inches =
      double.tryParse(inchesText) ?? 0;

  if (feet < 0 || inches < 0) {
    return null;
  }

  return ((feet * 12) + inches) * 2.54;
}

double? _getWeightKg() {
  final value =
      _weightController.text.trim();

  if (value.isEmpty) {
    return null;
  }

  return double.tryParse(value);
}

int? _getSystolicBP() {
  final value =
      _systolicBPController.text.trim();

  if (value.isEmpty) {
    return null;
  }

  return int.tryParse(value);
}
int? _getDiastolicBP() {
  final value =
      _diastolicBPController.text.trim();

  if (value.isEmpty) {
    return null;
  }

  return int.tryParse(value);
}
  //-------------------------------------------------------------------------
  // Generate
  //-------------------------------------------------------------------------

  Widget _buildGenerateButton() {

    return SizedBox(

      height: 52,

      child:
          FilledButton.icon(

        onPressed:
            controller.canGenerateNext
                ? _generatePrescription
                : null,

        icon:
            const Icon(
          Icons.print,
        ),

        label:
            const Text(
          "Generate Prescription",
        ),

      ),

    );

  }


Patient _buildNewPatient() {
  return Patient(
    id: "",
    ppid: "",
    firstName: _firstNameController.text.trim(),
    middleName: _middleNameController.text.trim(),
    lastName: _lastNameController.text.trim(),
    guardianPPID:
      _guardianPPIDController.text
              .trim()
              .isEmpty
          ? null
          : _guardianPPIDController.text
              .trim()
              .toUpperCase(),        
    dob: _dob,
    gender: _gender,
    mobile: _mobileController.text.trim(),
    loginEmail: _loginEmailController.text.trim(),
    bloodGroup: _selectedBloodGroup,
    addressLine1: _address1Controller.text.trim(),
    addressLine2: _address2Controller.text.trim(),
    city: _cityController.text.trim(),
    state: _stateController.text.trim(),
    countryId: _selectedCountryId!,
    pinCode: _pinCodeController.text.trim(),
  );
}

bool _validateVitals() {
  final systolic =
      _systolicBPController.text.trim();

  final diastolic =
      _diastolicBPController.text.trim();

  if (systolic.isEmpty &&
      diastolic.isEmpty) {
    return true;
  }

  if (systolic.isEmpty ||
      diastolic.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Please enter both systolic and diastolic BP.",
        ),
      ),
    );

    return false;
  }

  return true;
}

  Future<void> _generatePrescription() async {

if (!_validateVitals()) {
  return;
}
    // =========================================================================
  // Build patient from NEW patient form
  // =========================================================================

  if (widget.mode == PatientMode.newPatient) {

    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "First Name and Last Name are required.",
          ),
        ),
      );

      return;
    }

     if (_selectedCountryId == null ||
      _selectedCountryId!.isEmpty) {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Please select a country.",
        ),
      ),
    );

    return;
  }

    final patient = _buildNewPatient();

    controller.setPatient(patient);
  }

  // =========================================================================
  // Copy UI values into the prescription ViewModel
  // =========================================================================

  controller.prescription
    ..chiefComplaint =
        _chiefComplaintController.text.trim()
    ..examination =
        _examinationController.text.trim()
    ..diagnosis =
        _diagnosisController.text.trim()
    ..advice =
        _adviceController.text.trim()
    ..remarks =
        _remarksController.text.trim()
    ..followUpDate =
        _followUpDate
    ..heightCm =
      _getHeightCm()

  ..weightKg =
      _getWeightKg()

  ..systolicBP =
      _getSystolicBP()

  ..diastolicBP =
      _getDiastolicBP();

  controller.prescription.printLetterHead =
      controller.printLetterhead;

  // =========================================================================
  // Persist prescription
  // =========================================================================

  final result =
      await controller.generatePrescription();

  if (!mounted) {
    return;
  }

  // =========================================================================
  // Handle backend failure
  // =========================================================================

  if (!result.success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.message,
        ),
      ),
    );

    return;
  }

  // =========================================================================
  // Extract backend response
  // =========================================================================

  if (result.data is! Map) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Prescription was saved, but PDF data was not returned.",
        ),
      ),
    );

    return;
  }

  final data =
      Map<String, dynamic>.from(
    result.data as Map,
  );

  // =========================================================================
  // Extract persisted snapshot
  // =========================================================================

  final snapshotJson =
      data["snapshot"];

  if (snapshotJson is! Map) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Prescription was saved, but its snapshot was not returned.",
        ),
      ),
    );

    return;
  }

  final snapshot =
      PrescriptionSnapshot.fromJson(
    Map<String, dynamic>.from(
      snapshotJson,
    ),
  );

  // =========================================================================
  // Prescription date
  // =========================================================================

  final prescriptionDate =
      data["prescriptionDate"]?.toString();

  if (prescriptionDate == null ||
      prescriptionDate.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Prescription was saved, but its date was not returned.",
        ),
      ),
    );

    return;
  }

  // // =========================================================================
  // // Prescription QR
  // // =========================================================================
  // //
  // // The backend can later return a secure QR URL/token here.
  // //
  // // Example:
  // //
  // // https://prescriptor.app/r/abc123
  // //
  // // We intentionally do NOT put the prescription JSON into the QR code.
  // // =========================================================================

  // final prescriptionQrData =
  //     data["prescriptionQrData"]?.toString();

  // =========================================================================
// Patient QR
// =========================================================================
//
// The QR code contains only the patient's PPID.
// No prescription, diagnosis, medicine, or clinical data is stored in QR.
// =========================================================================
debugPrint(
  "QR PPID = [${snapshot.patient.ppid}]",
);
final prescriptionQrData =
    _buildPatientQrData(
  snapshot.patient.ppid,
);

  // =========================================================================
  // Generate PDF
  // =========================================================================

  try {
    final Uint8List pdfBytes =
        await pdfService.generatePrescriptionPdf(
      snapshot: snapshot,

      selectedTheme:
          
               widget.masterData
              .prescriptionLayout
              .selectedTheme,

      prescriptionQrData:
          prescriptionQrData,

      prescriptionDate:
          _formatPrescriptionDate(
            prescriptionDate,
          ),
    );

    if (!mounted) {
      return;
    }

    // =========================================================================
    // Open Print Preview
    // =========================================================================

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PrintPreviewScreen(
          pdfBytes: pdfBytes,
        ),
      ),
    );
  } catch (error) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Unable to generate prescription PDF: $error",
        ),
      ),
    );
  }
}

String _buildPatientQrData(
  String ppid,
) {
  return ppid.trim();
}

String _formatPrescriptionDate(
  String value,
) {
  final date =
      DateTime.tryParse(value);

  if (date == null) {
    return value;
  }

  return _formatDate(date);
}
  //-------------------------------------------------------------------------
  // Date picker
  //-------------------------------------------------------------------------

  Future<void> _selectDob() async {

    final date =
        await showDatePicker(

      context:
          context,

      firstDate:
          DateTime(1900),

      lastDate:
          DateTime.now(),

      initialDate:
          _dob ??
              DateTime(
                1990,
              ),

    );


    if (date == null) {
      return;
    }


    setState(() {

      _dob = date;

      _dobController.text =
          _formatDate(date);

    });

  }


  Future<void> _selectFollowUpDate() async {

    final date =
        await showDatePicker(

      context:
          context,

      firstDate:
          DateTime.now(),

      lastDate:
          DateTime.now().add(
        const Duration(
          days: 3650,
        ),
      ),

      initialDate:
          _followUpDate ??
              DateTime.now(),

    );


    if (date == null) {
      return;
    }


    setState(() {

      _followUpDate = date;

      _followUpDateController.text =
          _formatDate(date);

    });

  }


  //-------------------------------------------------------------------------
  // Common Text Field
  //-------------------------------------------------------------------------

  Widget _textField(
    String label,
    TextEditingController controller, {

    bool required = false,

    int maxLines = 1,

    TextInputType? keyboardType,

  }) {

    return Padding(

      padding:
          const EdgeInsets.only(
        bottom: 12,
      ),

      child:
          TextFormField(

        controller:
            controller,

        maxLines:
            maxLines,

        keyboardType:
            keyboardType,

        decoration:
            InputDecoration(

          labelText:
              required
                  ? "$label *"
                  : label,

          border:
              const OutlineInputBorder(),

        ),

      ),

    );

  }


  Widget _dateField(
    String label,
    TextEditingController controller, {

    required VoidCallback onTap,

  }) {

    return Padding(

      padding:
          const EdgeInsets.only(
        bottom: 12,
      ),

      child:
          TextFormField(

        controller:
            controller,

        readOnly:
            true,

        onTap:
            onTap,

        decoration:
            InputDecoration(

          labelText:
              label,

          border:
              const OutlineInputBorder(),

          suffixIcon:
              const Icon(
            Icons.calendar_today,
          ),

        ),

      ),

    );

  }

}