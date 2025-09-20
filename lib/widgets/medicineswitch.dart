import 'package:docautomations/common/appcolors.dart';
import 'package:docautomations/datamodels/prescriptionData.dart';
import 'package:flutter/material.dart';
import 'package:docautomations/validationhandling/validation.dart';
import 'package:docautomations/validationhandling/validator.dart';

class MedicineSwitch extends StatefulWidget {
  final Prescriptiondata prescription; // Passed prescription

  const MedicineSwitch({
    super.key,
    required this.prescription,
  });

  @override
  State<MedicineSwitch> createState() => MedicineSwitchState();
}

class MedicineSwitchState extends State<MedicineSwitch> {
  late bool istabletType;
  late String unitofmeasure;
  late String medicinetype;

  final tabNameController = TextEditingController();
  final unitofmeasureController = TextEditingController();

  @override
  void initState() {
    super.initState();
    istabletType = widget.prescription.isTablet ?? true;
    unitofmeasure = istabletType ? 'mg' : 'ml';
    medicinetype = istabletType ? 'Tablet' : 'Syrup';

    // Initialize text controllers if needed
    tabNameController.text = widget.prescription.drugName ?? '';
    //unitofmeasureController.text = widget.prescription.drugUnit.toString();
    unitofmeasureController.text = widget.prescription.drugUnit?.toString() ?? '';

    }

  void _toggleSwitch(bool value) {
    setState(() {
      istabletType = value;
      unitofmeasure = istabletType ? 'mg' : 'ml';
      medicinetype = istabletType ? 'Tablet' : 'Syrup';

      // Update the prescription object directly
      widget.prescription.isTablet = istabletType;
      widget.prescription.isMeasuredInMg = istabletType;
    });
  }

  @override
  void dispose() {
    tabNameController.dispose();
    unitofmeasureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Column(
        children: [
           FittedBox(
            fit :BoxFit.scaleDown,
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.all(10),
                child: 
                
                Text('Medicine (Tablet or Syrup)'),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Switch(
                  value: istabletType,
                  onChanged: _toggleSwitch,
                  activeColor: Colors.blue,
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey.shade300,
                ),
              ),
            ],
          ),),
      
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              autofocus: true,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Enter $medicinetype Name:',
              ),
              controller: tabNameController,
              onChanged: (value) {
                widget.prescription.drugName = value;
              },
              validator: Validator.apply(
                context,
                const [RequiredValidation()],
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child:
          
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text('Unit of Measure', textAlign: TextAlign.left),
              ),
              SizedBox(
                width: 150,
                child: TextFormField(
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Units in $unitofmeasure',
                    hintTextDirection: TextDirection.rtl,
                    errorMaxLines: 2,
                  ),
                  controller: unitofmeasureController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    //widget.prescription.drugUnit = int.tryParse(value); //nulll if empty
                    widget.prescription.drugUnit = value.isEmpty ? null : int.tryParse(value);
    //                 if (value.isEmpty) {
    //   widget.prescription.drugUnit = null; // or leave unchanged
    // } else {
    //   widget.prescription.drugUnit = int.tryParse(value);
    // }
                  },
                  validator: Validator.apply(
                    context,
                    const [RequiredValidation(), NumericValidation()],
                  ),
                ),
              ),
              Text('  $unitofmeasure', textAlign: TextAlign.left),
            ],
          ),),
        ],
      ),
    );
  }
}
