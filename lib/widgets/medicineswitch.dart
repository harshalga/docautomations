
// import 'package:docautomations/common/appcolors.dart';
// import 'package:docautomations/datamodels/prescriptionData.dart';
// import 'package:flutter/material.dart';
// import 'package:docautomations/validationhandling/validation.dart';
// import 'package:docautomations/validationhandling/validator.dart';
// import 'package:provider/provider.dart';




// class MedicineSwitch extends StatefulWidget {
   
// final Prescriptiondata prescription; // <--- Add this
//    bool istablet=true; 
//   String unitofmeasure = 'mg';
//   String medicinetype = 'Tablet';
  
//    MedicineSwitch(
//     {
//       super.key,required this.prescription
//       });

//   @override
//   State<MedicineSwitch> createState() => MedicineSwitchState();
// }



// class MedicineSwitchState extends State<MedicineSwitch> {
//   late bool istabletType;
//   String unitofmeasure = 'mg';
//   String medicinetype = 'Tablet'; 
//   final tabNameController = TextEditingController();
//   final unitofmeasureController = TextEditingController();
//   @override
//   void initState()
//   {
//     super.initState();
//     istabletType= widget.istablet;
//     unitofmeasure = (istabletType == true ? 'mg' : 'ml');
//     medicinetype= (istabletType == true ? 'Tablet' : 'Syrup');
//     context.read<Prescriptiondata>().updateIsTablet(istabletType);
//     context.read<Prescriptiondata>().updateIsMeasuredInMg(istabletType);
//   }

//  void _toggleSwitch(BuildContext context,  bool value) {
//     setState(() {
      
//       istabletType = value;
//       context.read<Prescriptiondata>().updateIsTablet(value);
//       context.read<Prescriptiondata>().updateIsMeasuredInMg(value);
//       unitofmeasure = (istabletType == true ? 'mg' : 'ml');
//       medicinetype= (istabletType == true ? 'Tablet' : 'Syrup');
//     });
    
//   }


// @override
//   void dispose() {
//     // Clean up the controller when the widget is disposed.
//     tabNameController.dispose();
//     unitofmeasureController.dispose();
//     super.dispose();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return 
//     Container(padding: const EdgeInsets.all(10),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(10),
//       boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.3),blurRadius:10,
//       offset: Offset.zero)],
//     ),
//     child: Column(
//       children:[
//               Row(

//                 children: [
//                   const Padding(
//                     padding: EdgeInsets.all(10),
//                     child: Text('Medicine (Tablet or Syrup) '),
//                   ),
                   
//                   Padding(
//                   padding: const EdgeInsets.all(10),

//                   child:  Switch(
//                     // This bool value toggles the switch.
                    
//                   value: istabletType,
                    
                    
//                     onChanged:(value) => _toggleSwitch(context, value), // Passing context//_toggleSwitch,
//                     activeColor: Colors.blue,
//                     inactiveThumbColor: Colors.grey,
//                     inactiveTrackColor: Colors.grey.shade300
//                   )  ) ,
                  
                  
//                 ],
//               ),
           
              

//               Padding(
//                 padding: const EdgeInsets.all(8),
//                 child: TextFormField(
//                   autofocus: true,
//                   decoration:  InputDecoration(
//                       border: const OutlineInputBorder(),
//                       labelText: 'Enter $medicinetype Name : '),
//                   controller: tabNameController,
//                   onChanged: (value)
//                   {
//                     context.read<Prescriptiondata>().updateDrugName(value);
//                   },
//                   validator: Validator.apply(context, const [RequiredValidation()]),
                  
//                 )),

//                    Row (children: [
                
//                 const Padding(padding:  EdgeInsets.all(8),

//                 child: Text('Unit of Measure ', textAlign: TextAlign.left),
//                 ),
                
//               SizedBox(
//                 width: 150,
//                 child: 
//                   TextFormField(
//                     decoration: InputDecoration(
//                         border: const OutlineInputBorder(),
//                         hintText: 'Units in $unitofmeasure',
//                         hintTextDirection: TextDirection.rtl,
//                         errorMaxLines: 2),
//                     controller: unitofmeasureController,
//                     onChanged: (value)
//                   {
//                     context.read<Prescriptiondata>().updateDrugUnit(int.parse(value));
//                   },
//                     validator : Validator.apply(
//                       context,
//                        const [RequiredValidation(),NumericValidation()])
                    
//                   )),
                  

//                  Text( overflow: TextOverflow.ellipsis,'  $unitofmeasure', textAlign: TextAlign.left),
//                 //),
//               ],),

//       ]
//     ));
    
   
//   }
// }
import 'package:docautomations/common/appcolors.dart';
import 'package:docautomations/datamodels/prescriptionData.dart';
import 'package:flutter/material.dart';
import 'package:docautomations/validationhandling/validation.dart';
import 'package:docautomations/validationhandling/validator.dart';

class MedicineSwitch extends StatefulWidget {
  final Prescriptiondata prescription; // Passed prescription

  const MedicineSwitch({
    Key? key,
    required this.prescription,
  }) : super(key: key);

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
    if (widget.prescription.drugUnit != null) {
      unitofmeasureController.text = widget.prescription.drugUnit.toString();
    }
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
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text('Medicine (Tablet or Syrup)'),
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
          ),
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
                    widget.prescription.drugUnit = int.tryParse(value) ?? 0;
                  },
                  validator: Validator.apply(
                    context,
                    const [RequiredValidation(), NumericValidation()],
                  ),
                ),
              ),
              Text('  $unitofmeasure', textAlign: TextAlign.left),
            ],
          ),
        ],
      ),
    );
  }
}
