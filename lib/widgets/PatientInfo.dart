import 'package:docautomations/common/appcolors.dart';
import 'package:docautomations/validationhandling/validation.dart';
import 'package:docautomations/validationhandling/validator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Patientinfo extends StatefulWidget {
  // final void Function(String name, String age, String gender, String keycomplaint,
  // String examination,String diagnostics )? onChanged;
  // const Patientinfo({super.key, this.onChanged});
  const Patientinfo({super.key});
  @override
  State<Patientinfo> createState() => PatientinfoState();
}

class PatientinfoState extends State<Patientinfo> {
  final TextEditingController tabNameController = TextEditingController();
   final TextEditingController keyComplaintcontroller = TextEditingController();
   final TextEditingController examinationcontroller = TextEditingController();
   final TextEditingController diagnoscontroller = TextEditingController();
   final TextEditingController ageController = TextEditingController();
   final TextEditingController remarkscontroller =TextEditingController();
   final TextEditingController followupDatecontroller = TextEditingController();
  String selectedGender = "Male";

// void _notifyParent() {
//     widget.onChanged?.call(
//       tabNameController.text,
//       _ageController.text,
//       _selectedGender,
//       _keyComplaintcontroller.text,
//       _examinationcontroller.text,
//       _diagnoscontroller.text,
//     );
//   }

Future<void> _selectNextFollowupDate () async
{
  DateTime? _picked=  await showDatePicker(context: context, firstDate: DateTime(2000),
   lastDate: DateTime(2100)         
   ,initialDate: DateTime.now());

   if (_picked != null)
   {
    setState(() {
       String formattedDate = DateFormat('dd/MM/yyyy').format(_picked);
      followupDatecontroller.text = formattedDate;
    });
          
   }

}

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    ageController.dispose();
    tabNameController.dispose();
    keyComplaintcontroller.dispose();
    examinationcontroller.dispose();
    diagnoscontroller.dispose();
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
                  //onChanged: (_) => _notifyParent(),
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
                  SizedBox(
                    width: 50,
                    child:TextFormField(                  
                  keyboardType:TextInputType.number ,
                  decoration:  const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter patient Age  '),
                  controller: ageController,
                  //onChanged: (_) => _notifyParent(),
                  validator: Validator.apply(context, const [RequiredValidation(),NumericValidation(),ageValidation()])
                )  ,
                  )
                  )
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
          value: selectedGender,
          decoration: const InputDecoration(labelText: "Gender"),
          onChanged: (value) {
            setState(() {
              selectedGender = value!;
             // _notifyParent();
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
                       //onChanged: (_) => _notifyParent(),
                  controller: keyComplaintcontroller,
                  //validator: Validator.apply(context, const [RequiredValidation()])
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
                       //onChanged: (_) => _notifyParent(),
                  controller: examinationcontroller,
                  //validator: Validator.apply(context, const [RequiredValidation()])
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
                  controller: diagnoscontroller,
                  // onChanged: (_) => _notifyParent(),
                  //validator: Validator.apply(context, const [RequiredValidation()])
                )   )
                ],
              ),
Row(

                children: [
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('Next Followup Date: '),
                  ),
                  Expanded(child: 
                TextFormField(
                  keyboardType:TextInputType.number ,
                  decoration:  const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Next Follow up date  ',
                      filled: true,
                      prefixIcon: Icon(Icons.calendar_today),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      )
                      ),
                      readOnly: true  ,
                      onTap: (){_selectNextFollowupDate();},
                  controller: followupDatecontroller,
                  //onChanged: (_) => _notifyParent(),
                  //validator: Validator.apply(context, const [RequiredValidation()])
                )   )
                ],
              ),
              Row(

                children: [
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('Remarks: '),
                  ),
                  Expanded(child: 
                TextFormField(
                  keyboardType:TextInputType.number ,
                  decoration:  const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Remarks  '),
                  controller: remarkscontroller,
                  //onChanged: (_) => _notifyParent(),
                 // validator: Validator.apply(context, const [RequiredValidation()])
                )   )
                ],
              ),

      ]
    ));
  }
}