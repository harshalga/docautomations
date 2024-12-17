
import 'package:flutter/material.dart';
import 'package:docautomations/validationhandling/validation.dart';
import 'package:docautomations/validationhandling/validator.dart';




class MedicineSwitch extends StatefulWidget {
   

   bool istablet=true; 
  String unitofmeasure = 'mg';
  String medicinetype = 'Tablet';
  
   MedicineSwitch(
    {
      Key?key
      }):super(key:key);

  @override
  State<MedicineSwitch> createState() => MedicineSwitchState();
}



class MedicineSwitchState extends State<MedicineSwitch> {
  late bool istabletType;
  String unitofmeasure = 'mg';
  String medicinetype = 'Tablet'; 
  final tabNameController = TextEditingController();
  final unitofmeasureController = TextEditingController();
  @override
  void initState()
  {
    super.initState();
    istabletType= widget.istablet;
    unitofmeasure = (istabletType == true ? 'mg' : 'ml');
    medicinetype= (istabletType == true ? 'Tablet' : 'Syrup');
  }

 void _toggleSwitch(bool value) {
    setState(() {
      
      istabletType = value;
      unitofmeasure = (istabletType == true ? 'mg' : 'ml');
      medicinetype= (istabletType == true ? 'Tablet' : 'Syrup');
    });
    
  }


@override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    tabNameController.dispose();
    unitofmeasureController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children:[
              Row(

                children: [
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('Select Medicine (Tablet or Syrup) '),
                  ),
                   
                  Padding(
                  padding: EdgeInsets.all(10),

                  child:  Switch(
                    // This bool value toggles the switch.
                    
                  value: istabletType,
                    
                    
                    onChanged:_toggleSwitch,
                    activeColor: Colors.blue,
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey.shade300
                  )  ) ,
                  
                  
                ],
              ),
           
              

              Padding(
                padding: const EdgeInsets.all(8),
                child: TextFormField(
                  autofocus: true,
                  decoration:  InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Enter $medicinetype Name : '),
                  controller: tabNameController,
                  validator: Validator.apply(context, const [RequiredValidation()]),
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Please enter $medicinetype name !!';
                  //   }
                  //   return null;
                  // },
                )),

                   Row (children: [
                
                const Padding(padding:  EdgeInsets.all(8),

                child: Text('Unit of Measure ', textAlign: TextAlign.left),
                ),
                
              Container(
                width: 150,
                child: 
                  TextFormField(
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: 'Units in $unitofmeasure',
                        hintTextDirection: TextDirection.rtl,
                        errorMaxLines: 2),
                    controller: unitofmeasureController,
                    
                    validator : Validator.apply(
                      context,
                       const [RequiredValidation(),NumericValidation()])
                    
                  )),
                   //Padding(padding:  EdgeInsets.all(4),

                 Text( overflow: TextOverflow.ellipsis,'  $unitofmeasure', textAlign: TextAlign.left),
                //),
              ],),

      ]
    );
    
   
  }
}
