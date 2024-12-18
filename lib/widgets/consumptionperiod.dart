import 'package:docautomations/common/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:docautomations/validationhandling/validation.dart';
import 'package:docautomations/validationhandling/validator.dart';
import 'package:collection/collection.dart';

class ConsumptionPeriod extends StatefulWidget
{
  const ConsumptionPeriod({Key?key}):super(key:key);
  
  @override
  State<ConsumptionPeriod> createState() => ConsumptionPeriodState();



}


typedef PeriodEntry = DropdownMenuEntry<PeriodLabel>;
// DropdownMenuEntry labels and values for the first dropdown menu.

enum PeriodLabel
{
  daysperiod('days',1),
  monthsperiod('months',2) ; 
  const PeriodLabel(this.label, this.val);
  final String label;
  final int val;

  static final List<PeriodEntry> entries =
  UnmodifiableListView<PeriodEntry>(
    values.map<PeriodEntry>(
      (PeriodLabel period )=> PeriodEntry(value: period,
      label: period.label,      
      )
    )
  ) ;
}

class ConsumptionPeriodState extends State<ConsumptionPeriod> {
   final TextEditingController periodController = TextEditingController();
   final TextEditingController durationController = TextEditingController();
  PeriodLabel? selectedPeriod;
  String? selectedLabel ;
  
   @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    periodController.dispose();
    durationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
  
  if ( selectedPeriod!=null)
  {
    selectedLabel= selectedPeriod!.label;

  }
  else{
    selectedLabel= 'days';
  }
    return Container(
      padding:EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    boxShadow:[ BoxShadow(color: AppColors.secondary.withOpacity(0.3),blurRadius: 10,
    offset :Offset.zero),]),
    child: Row(children: [
      // Text("Duration", textAlign: TextAlign.left),
      // const SizedBox(width:5),
      DropdownMenu(dropdownMenuEntries: PeriodLabel.entries,
      initialSelection: PeriodLabel.daysperiod,
      controller: periodController,
      requestFocusOnTap: true,
      label: const Text('Select Period'),
      onSelected: (PeriodLabel? period){
        setState(() {
          selectedPeriod = period;
          selectedLabel=selectedPeriod!.label;
        });
      },
      ),
      const SizedBox(width:5),
      Expanded(child: 
      TextFormField(
        controller: durationController,
        decoration: InputDecoration(border: const OutlineInputBorder(),
        labelText: 'Enter duration in $selectedLabel'),
      )),
    ],
    

    
    ),
    
    );
    
  }
}