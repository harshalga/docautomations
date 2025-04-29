import 'package:docautomations/common/appcolors.dart';
import 'package:docautomations/validationhandling/validation.dart';
import 'package:docautomations/validationhandling/validator.dart';
import 'package:flutter/material.dart';

class Patientinfo extends StatefulWidget {
  final void Function(String name, String age, String gender, String keycomplaint,
  String examination,String diagnostics )? onChanged;
  const Patientinfo({super.key, this.onChanged});

  @override
  State<Patientinfo> createState() => _PatientinfoState();
}

class _PatientinfoState extends State<Patientinfo> {
  final TextEditingController tabNameController = TextEditingController();
   final TextEditingController _keyComplaintcontroller = TextEditingController();
   final TextEditingController _examinationcontroller = TextEditingController();
   final TextEditingController _diagnoscontroller = TextEditingController();
   final _ageController = TextEditingController();
  String _selectedGender = "Male";

void _notifyParent() {
    widget.onChanged?.call(
      tabNameController.text,
      _ageController.text,
      _selectedGender,
      _keyComplaintcontroller.text,
      _examinationcontroller.text,
      _diagnoscontroller.text,
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _ageController.dispose();
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
                      labelText: 'Enter patient name  '),
                  controller: tabNameController,
                  onChanged: (_) => _notifyParent(),
                  validator: Validator.apply(context, const [RequiredValidation()])
                )   )
                ],
              ),
//Age
              Row(

                children: [
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('Age: '),
                  ),
                  Expanded(child: 
                TextFormField(
                  keyboardType:TextInputType.number ,
                  decoration:  const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter patient Age  '),
                  controller: _ageController,
                  onChanged: (_) => _notifyParent(),
                  validator: Validator.apply(context, const [RequiredValidation()])
                )   )
                ],
              ),
              //Gender
               Row(

                children: [
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('Gender: '),
                  ),
                  Expanded(child: 
                  DropdownButtonFormField<String>(
          value: _selectedGender,
          decoration: const InputDecoration(labelText: "Gender"),
          onChanged: (value) {
            setState(() {
              _selectedGender = value!;
              _notifyParent();
            });
          },
          items: const [
            DropdownMenuItem(value: "Male", child: Text("Male")),
            DropdownMenuItem(value: "Female", child: Text("Female")),
            DropdownMenuItem(value: "Other", child: Text("Other")),
          ],
        ),   )
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
                       onChanged: (_) => _notifyParent(),
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
                       onChanged: (_) => _notifyParent(),
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
                   onChanged: (_) => _notifyParent(),
                  validator: Validator.apply(context, const [RequiredValidation()])
                )   )
                ],
              ),

      ]
    ));
  }
}