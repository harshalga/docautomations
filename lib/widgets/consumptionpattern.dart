import 'package:docautomations/common/appcolors.dart';
import 'package:docautomations/datamodels/prescriptionData.dart';
import 'package:flutter/material.dart';

class ConsumptionPattern extends StatefulWidget {
  final Prescriptiondata prescription; // Accept prescription data

  const ConsumptionPattern({
    super.key,
    required this.prescription,
  });

  @override
  State<ConsumptionPattern> createState() => ConsumptionPatternState();
}

class ConsumptionPatternState extends State<ConsumptionPattern> {
  late List<bool> isSelected;

  @override
  void initState() {
    super.initState();
    _syncFromPrescription();
  }

  @override
  void didUpdateWidget(covariant ConsumptionPattern oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If a *different* Prescriptiondata is passed, resync.
    if (oldWidget.prescription != widget.prescription) {
      _syncFromPrescription();
    }
  }

  void _syncFromPrescription() {
    bool isBeforeFood = widget.prescription.isBeforeFood??true;
    isSelected = [isBeforeFood, !isBeforeFood];
  }

  void _toggleConsumption(int newIndex) {
    setState(() {
      for (int index = 0; index < isSelected.length; index++) {
        isSelected[index] = (index == newIndex);
      }
      bool newValue = (newIndex == 0);
      widget.prescription.updateIsBeforeFood(newValue);
    });
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Consumption pattern of Medication',
            textAlign: TextAlign.left,
          ),
          ToggleButtons(
            isSelected: isSelected,
            selectedColor: Colors.white,
            color: Colors.blue,
            fillColor: Colors.lightBlue.shade900,
            splashColor: Colors.red,
            highlightColor: Colors.orange,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            renderBorder: true,
            borderColor: Colors.black,
            borderWidth: 1.5,
            borderRadius: BorderRadius.circular(10),
            selectedBorderColor: Colors.pink,
            onPressed: _toggleConsumption,
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Before Food', style: TextStyle(fontSize: 18)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('After Food', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

