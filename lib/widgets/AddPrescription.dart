import 'package:docautomations/common/appcolors.dart';
import 'package:docautomations/datamodels/prescriptionData.dart';
import 'package:docautomations/widgets/consumptionpattern.dart';
import 'package:docautomations/widgets/consumptionperiod.dart';
import 'package:docautomations/widgets/frequency.dart';
import 'package:docautomations/widgets/instructions.dart';
import 'package:docautomations/widgets/medicineswitch.dart';
import 'package:flutter/material.dart';

class AddPrescription extends StatefulWidget {
  final String title;
  final Prescriptiondata? existingPrescription; // Optional parameter for editing

  const AddPrescription({super.key, required this.title, this.existingPrescription});

  @override
  State<AddPrescription> createState() => AddPrescriptionState();
}

class AddPrescriptionState extends State<AddPrescription> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                )),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Center(
        child: AddPrescriptionScreen(prescription: widget.existingPrescription),
      ),
    );
  }
}

class AddPrescriptionScreen extends StatefulWidget {
  final Prescriptiondata? prescription; // Optional parameter for editing

  const AddPrescriptionScreen({super.key, this.prescription});

  @override
  State<AddPrescriptionScreen> createState() => AddPrescriptionScreenState();
}

class AddPrescriptionScreenState extends State<AddPrescriptionScreen> {
  late Prescriptiondata _prescription;

  @override
  void initState() {
    super.initState();
    _prescription = widget.prescription ?? Prescriptiondata(); // If editing, use existing prescription
  }

  final _formKey = GlobalKey<FormState>();

  bool istabletSel = true;
  String unitofmeasure = 'mg';
  String medicinetype = 'Tablet';

  final GlobalKey<MedicineSwitchState> _MedicineSwitchKey = GlobalKey<MedicineSwitchState>();
  final GlobalKey<FrequencyWidgetState> _frequencyKey = GlobalKey<FrequencyWidgetState>();
  //final medicinenameKey = GlobalKey();
  // Keys for specific form fields INSIDE Patientinfo
  final GlobalKey<FormFieldState<String>> _medicinenameKey =
      GlobalKey<FormFieldState<String>>();
      final GlobalKey<FormFieldState<String>> _dosageFieldKey =
    GlobalKey<FormFieldState<String>>();
      final GlobalKey<FormFieldState<bool>> _freqFieldKey =
    GlobalKey<FormFieldState<bool>>();
    final GlobalKey<FormFieldState<String>> _durationFieldKey =
    GlobalKey<FormFieldState<String>>();

  static const descTextStyle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w800,
    fontFamily: 'Roboto',
    letterSpacing: 0.5,
    fontSize: 18,
    height: 2,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: Offset.zero,
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: DefaultTextStyle.merge(
              style: descTextStyle,
              child: Column(
                children: [
                  MedicineSwitch(key:_MedicineSwitchKey, medicinenameKey: _medicinenameKey,
                   dosageFieldKey: _dosageFieldKey ,  prescription: _prescription),
                  const SizedBox(height: 10),
                  FrequencyWidget(key: _frequencyKey , freqFieldKey: _freqFieldKey, prescription: _prescription),
                  const SizedBox(height: 10),
                  ConsumptionPattern(prescription: _prescription),
                  const SizedBox(height: 10),
                  ConsumptionPeriod( durationFieldKey: _durationFieldKey, prescriptionData: _prescription),
                  const SizedBox(height: 10),
                  Instructions(prescriptionData: _prescription),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: ElevatedButton(
                      onPressed: () async  {
                        // Step 1: Validate form fields
                        final isFormValid = _formKey.currentState!.validate();
                        
                        // Step 2: Validate frequency selection
                        //final isFrequencyValid = _frequencyKey.currentState?.validateFrequencySelection() ?? false;
                        //if (!isFormValid || !isFrequencyValid ) {
                        if (!isFormValid  ) {
                            await _scrollToFirstError();
                            return;
                         }

                          //if (isFormValid && isFrequencyValid) {
                          if (isFormValid ) {
                            Navigator.pop(context, _prescription);
                          }
                      },
                      child: const Text('Save Prescription'),
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

  Future<void> _scrollToFirstError() async {
  // Let Flutter paint the error messages first
  await Future.delayed(const Duration(milliseconds: 100));

  // Fields in the order you want to check
  //final fieldKeys = <GlobalKey<FormFieldState<String>>>[
    final fieldKeys = <GlobalKey>[
    _medicinenameKey,
    _dosageFieldKey,
    _freqFieldKey,
    _durationFieldKey,
    
  ];

  for (final key in fieldKeys) {
    final state = key.currentState;
    final context = key.currentContext;

    //if (state != null && state.hasError && context != null) {
    if (state is FormFieldState && state.hasError && context != null) {
      await Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.3, // keeps field slightly below top
      );
      return;
    }
  }
}

}
