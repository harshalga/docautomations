import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:docautomations/controllers/add_prescription_controller.dart';
import 'package:docautomations/datamodels/master/patient.dart';

import 'package:docautomations/datamodels/master/patient_doctor.dart';
import 'package:docautomations/datamodels/master/patient_mode.dart';
import 'package:docautomations/repositories/prescription_repository.dart';


import 'package:docautomations/screens/prescription/add_prescription.dart';
import  'package:docautomations/datamodels/prescriptionData.dart';


class PatientPrescriptionScreen extends StatefulWidget {

  final PatientMode mode;

  final Patient? patient;

  final PatientDoctor? patientDoctor;


  const PatientPrescriptionScreen({

    super.key,

    required this.mode,

    this.patient,

    this.patientDoctor,

  });


  @override
  State<PatientPrescriptionScreen> createState() =>
      _PatientPrescriptionScreenState();

}


class _PatientPrescriptionScreenState
    extends State<PatientPrescriptionScreen> {

  late final AddPrescriptionController controller;

  bool _initialized = false;


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

  final _emailController =
      TextEditingController();

  final _address1Controller =
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


  String _gender = "Male";

  DateTime? _dob;

  DateTime? _followUpDate;


  @override
  void initState() {

    super.initState();

    controller =
        AddPrescriptionController(

      mode:
          widget.mode,

      patient:
          widget.patient,

      patientDoctor:
          widget.patientDoctor,

      prescriptionRepository:
          context.read<PrescriptionRepository>(),

    );

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

      _mobileController.text =
          patient.mobile;

      _emailController.text =
          patient.email;

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
    _emailController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pinCodeController.dispose();

    _chiefComplaintController.dispose();
    _examinationController.dispose();
    _diagnosisController.dispose();
    _adviceController.dispose();
    _remarksController.dispose();
    _followUpDateController.dispose();

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
                patient.ppid,
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
          _emailController,
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


  Future<void> _generatePrescription() async {

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
        _followUpDate;

  controller.prescription.printLetterHead =
      controller.printLetterhead;


  final result =
      await controller.generatePrescription();


  if (!mounted) return;


  if (!result.success) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(result.message),
      ),
    );

    return;

  }


  // PDF generation comes here.
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