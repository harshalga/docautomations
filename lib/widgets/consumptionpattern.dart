import 'package:docautomations/common/appcolors.dart';
import 'package:flutter/material.dart';


class ConsumptionPattern extends StatefulWidget
{
   const ConsumptionPattern({super.key});

  @override
  State<ConsumptionPattern> createState() => ConsumptionPatternState();
  
}

class ConsumptionPatternState extends State<ConsumptionPattern>{
  List<bool> isSelected = [true, false];
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   return Container(
   padding:const EdgeInsets.all(10),
   decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.3),blurRadius:10,
      offset: Offset.zero),],
   ),
   child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      
      const Text('Consumption pattern of Medication', textAlign: TextAlign.left,) ,

     
          ToggleButtons(
        // list of booleans
        isSelected: isSelected,
        // text color of selected toggle
        selectedColor: Colors.white,
       //fill color of selected toggle
       color: Colors.blue,
       // fill color of selected toggle
       fillColor: Colors.lightBlue.shade900,
       // when pressed, splash color is seen
        splashColor: Colors.red,
        // long press to identify highlight color
        highlightColor: Colors.orange,
        // if consistency is needed for all text style
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
          // border properties for each toggle
        renderBorder: true,
        borderColor: Colors.black,
        borderWidth: 1.5,
        borderRadius: BorderRadius.circular(10),
        selectedBorderColor: Colors.pink,
        // add widgets for which the users need to toggle
        children: const [ Padding(
    padding: EdgeInsets.symmetric(horizontal: 12),
    child: Text('Before Food', style: TextStyle(fontSize: 18)),
  ),
  Padding(
    padding: EdgeInsets.symmetric(horizontal: 12),
    child: Text('After Food', style: TextStyle(fontSize: 18)),
  )],
      // to select or deselect when pressed
  onPressed: (int newIndex) { 
    setState(() {
    // looping through the list of booleans values
    for (int index = 0; index < isSelected.length; index++) {
      // checking for the index value
      if (index == newIndex) {
        // one button is always set to true
        isSelected[index] = true;
      } else {
        // other two will be set to false and not selected
        isSelected[index] = false;
      }
    }
  });})
    ],
   ),
   );
  }

}