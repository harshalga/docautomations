
import 'package:docautomations/controllers/application_controller.dart';
import 'package:docautomations/repositories/doctor_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:docautomations/datamodels/master/country.dart';
import 'package:docautomations/datamodels/master/doctor_master.dart';
import 'package:docautomations/datamodels/response/doctor_profile.dart';

import 'package:docautomations/validationhandling/validator.dart';
import 'package:docautomations/validationhandling/validation.dart';


class ManageProfileScreen extends StatefulWidget {
  final DoctorRepository doctorRepository;

  const ManageProfileScreen({
    super.key,
    required this.doctorRepository,
  });

  @override
  State<ManageProfileScreen> createState() =>
      _ManageProfileScreenState();
}

class _ManageProfileScreenState
    extends State<ManageProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _specializationController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _registrationAuthorityController = TextEditingController();

  final _clinicNameController = TextEditingController();
  final _clinicAddressController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _pinCodeController = TextEditingController();

  final _mobileController = TextEditingController();
  final _alternateMobileController = TextEditingController();
  final _loginEmailController = TextEditingController();
  final _websiteController = TextEditingController();

  bool _loading = false;
  bool _initialized = false;
  String? _countryId;

  DoctorMaster? _originalDoctor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    final applicationController =
        context.read<ApplicationController>();

    final doctor =
        applicationController.masterData.doctorProfile.doctor;

    _originalDoctor = doctor;

    _nameController.text = doctor.doctorName;
    _qualificationController.text = doctor.qualification;
    _specializationController.text = doctor.specialization;
    _registrationNumberController.text =
        doctor.medicalRegistrationNumber;
    _registrationAuthorityController.text =
        doctor.registrationAuthority;

    _clinicNameController.text = doctor.clinicName;
    _clinicAddressController.text = doctor.clinicAddress;
    _cityController.text = doctor.city;
    _districtController.text = doctor.district;
    _stateController.text = doctor.state;
    _pinCodeController.text = doctor.pinCode;

    _mobileController.text = doctor.mobileNumber;
    _alternateMobileController.text =
        doctor.alternateMobileNumber;
    _loginEmailController.text = doctor.loginEmail;
    debugPrint('Doctor email from profile: "${doctor.loginEmail}"');
    _websiteController.text = doctor.website;

    _countryId = doctor.countryid?.isNotEmpty == true
        ? doctor.countryid
        : null;

    _initialized = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qualificationController.dispose();
    _specializationController.dispose();
    _registrationNumberController.dispose();
    _registrationAuthorityController.dispose();

    _clinicNameController.dispose();
    _clinicAddressController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _pinCodeController.dispose();

    _mobileController.dispose();
    _alternateMobileController.dispose();
    _loginEmailController.dispose();
    _websiteController.dispose();

    super.dispose();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    return null;
  }

  
Widget _field(
  String label,
  TextEditingController controller, {
  bool required = false,
  bool mobileNumber = false,
  TextInputType? keyboardType,
  int maxLines = 1,
  bool readOnly = false,
}) {
  final List<Validation<String>> validations = [];

  if (required) {
    validations.add(const RequiredValidation<String>());
  }

  if (mobileNumber) {
    validations.add(const MobileNumberValidation());
  }

  return TextFormField(
    controller: controller,
    readOnly: readOnly,
    keyboardType: keyboardType,
    maxLines: maxLines,
    validator: validations.isEmpty
        ? null
        : Validator.apply<String>(context, validations),
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      isDense: true,
    ),
  );
}


  Widget _section(String title, List<Widget> fields) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...fields.map(
              (field) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: field,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    

    setState(() => _loading = true);

    try {

       final original = _originalDoctor;

    if (original == null) {
      throw StateError('Doctor profile is not loaded.');
    }
      final updatedDoctor = DoctorMaster(
        id: original.id,
        doctorCode: original.doctorCode,
        medicalRegistrationNumber:
            _registrationNumberController.text.trim(),
        registrationAuthority:
            _registrationAuthorityController.text.trim(),
        doctorName: _nameController.text.trim(),
        qualification: _qualificationController.text.trim(),
        specialization: _specializationController.text.trim(),
        clinicName: _clinicNameController.text.trim(),
        clinicAddress: _clinicAddressController.text.trim(),
        city: _cityController.text.trim(),
        district: _districtController.text.trim(),
        state: _stateController.text.trim(),
        countryid: _countryId,
        pinCode: _pinCodeController.text.trim(),
        mobileNumber: _mobileController.text.trim(),
        alternateMobileNumber:
            _alternateMobileController.text.trim(),
        loginEmail: original.loginEmail,
        website: _websiteController.text.trim(),
        isSubscribed: original.isSubscribed,
        subscriptionExpiry: original.subscriptionExpiry,
      );

      final result =
          await widget.doctorRepository.updateDoctorProfile(
        updatedDoctor,
      );

      if (!mounted) return;

      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.message.isNotEmpty
                  ? result.message
                  : 'Unable to update profile.',
            ),
          ),
        );
        return;
      }

      // Fetch the complete server profile so layout, theme and
      // asset metadata remain authoritative.
      final DoctorProfile refreshedProfile =
          await widget.doctorRepository.fetchDoctorProfile();

      if (!mounted) return;

      context
          .read<ApplicationController>()
          .updateDoctorProfile(refreshedProfile);

      _originalDoctor = refreshedProfile.doctor;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final masterData =
        context.watch<ApplicationController>().masterData;

    final List<Country> countries = masterData.countries;

    final countryExists = countries.any(
      (country) => country.id == _countryId,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Profile'),
      ),
      body: !_initialized
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _section('Professional Details', [
                    _field(
                      'Doctor Name',
                      _nameController,
                      required: true,
                    ),
                    _field(
                      'Qualification',
                      _qualificationController,
                      required: true,
                    ),
                    _field(
                      'Specialization',
                      _specializationController,
                      required: true,
                    ),
                  ]),
                  _section('Medical Registration', [
                    _field(
                      'Medical Registration Number',
                      _registrationNumberController,
                      required: true,
                    ),
                    _field(
                      'Registration Council / Authority',
                      _registrationAuthorityController,
                      required: true,
                    ),
                  ]),
                  _section('Clinic Details', [
                    _field('Clinic Name', _clinicNameController, required: true),
                    _field(
                      'Clinic Address',
                      _clinicAddressController ,
                      required: true,
                      maxLines: 3,
                    ),
                    _field('City', _cityController, required: true),
                    _field('District', _districtController),
                    _field('State', _stateController , required: true),
                    DropdownButtonFormField<String>(
                      value: countryExists ? _countryId : null,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Country',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: countries
                          .map(
                            (country) =>
                                DropdownMenuItem<String>(
                              value: country.id,
                              child: Text(country.countryName),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => _countryId = value);
                      },
                    ),
                    _field(
                      'PIN Code',
                      _pinCodeController,
                      required: true,
                      keyboardType: TextInputType.number,
                      ),
                  ]),
                  _section('Contact Details', [
                    _field(
                      'Mobile Number',
                      _mobileController,
                      required: true,
                      mobileNumber: true,
                      keyboardType: TextInputType.phone,
                    ),
                    _field(
                      'Alternate Mobile Number',
                      _alternateMobileController,
                      keyboardType: TextInputType.phone,
                    ),
                    _field(
                      'Login Email',
                      _loginEmailController,
                      readOnly: true,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _field(
                      'Website',
                      _websiteController,
                      keyboardType: TextInputType.url,
                    ),
                  ]),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _loading ? null : _saveProfile,
                    icon: _loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      _loading ? 'Saving...' : 'Save Profile',
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
