import 'package:docautomations/common/appcolors.dart';
import 'package:docautomations/validationhandling/validation.dart';
import 'package:docautomations/validationhandling/validator.dart';
import 'package:flutter/material.dart';

class Patientinfo extends StatefulWidget {
  const Patientinfo({super.key});

  @override
  State<Patientinfo> createState() => _PatientinfoState();
}

class _PatientinfoState extends State<Patientinfo> {
  final TextEditingController tabNameController = TextEditingController();
   final TextEditingController _keyComplaintcontroller = TextEditingController();
   final TextEditingController _examinationcontroller = TextEditingController();
   final TextEditingController _diagnoscontroller = TextEditingController();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    tabNameController.dispose();
    _keyComplaintcontroller.dispose();
    _examinationcontroller.dispose();
    _diagnoscontroller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return  Container(padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.3),blurRadius:10,
      offset: Offset.zero)],
    ),
    child: Column(
      children:[
              Row(

                children: [
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('Name: '),
                  ),
                  Expanded(child: 
                TextFormField(
                  autofocus: true,
                  decoration:  const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter patient name : '),
                  controller: tabNameController,
                  validator: Validator.apply(context, const [RequiredValidation()])
                )   )
                ],
              ),
           
Row(

                children: [
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('Key Complaints: '),
                  ),
                  Expanded(child: 
                TextFormField(
                  
                  decoration:  const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter key complaint '),
                  controller: _keyComplaintcontroller,
                  validator: Validator.apply(context, const [RequiredValidation()])
                )   )
                ],
              ),
Row(

                children: [
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('Examination: '),
                  ),
                  Expanded(child: 
                TextFormField(
                  
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                   maxLines: 5,
                  decoration:  const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter examination inputs '),
                  controller: _examinationcontroller,
                  validator: Validator.apply(context, const [RequiredValidation()])
                )   )
                ],
              ),
             Row(

                children: [
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('Diagnostics: '),
                  ),
                  Expanded(child: 
                TextFormField(
                  
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                   maxLines: 5,
                  decoration:  const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter diagnosis inputs '),
                  controller: _diagnoscontroller,
                  validator: Validator.apply(context, const [RequiredValidation()])
                )   )
                ],
              ),

      ]
    ));
  }
}