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
                  MedicineSwitch(key: _MedicineSwitchKey, prescription: _prescription),
                  const SizedBox(height: 10),
                  FrequencyWidget(key: _frequencyKey, prescription: _prescription),
                  const SizedBox(height: 10),
                  ConsumptionPattern(prescription: _prescription),
                  const SizedBox(height: 10),
                  ConsumptionPeriod(prescriptionData: _prescription),
                  const SizedBox(height: 10),
                  Instructions(prescriptionData: _prescription),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: ElevatedButton(
                      onPressed: () {
                        // Step 1: Validate form fields
                        final isFormValid = _formKey.currentState!.validate();
  
                        // Step 2: Validate frequency selection
                        final isFrequencyValid = _frequencyKey.currentState?.validateFrequencySelection() ?? false;

                        if (isFormValid && isFrequencyValid) {
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
}
