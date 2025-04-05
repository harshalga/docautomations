import 'package:docautomations/common/appcolors.dart';
import 'package:docautomations/datamodels/prescriptionData.dart';
import 'package:flutter/material.dart';


class FrequencyWidget extends StatefulWidget
{
  
  const FrequencyWidget({super.key});

  @override
  State<FrequencyWidget> createState() => FrequencyWidgetState();
  
}

class FrequencyWidgetState extends State<FrequencyWidget>
{
    Prescriptiondata pescriptiondata=  Prescriptiondata(); // Initialize Model
    //List<bool> isSelected = [true, false,false,false];
    late List<bool> isSelected;

    @override
  void initState() {
    super.initState();
    // Convert stored bitField to list of booleans
    isSelected = pescriptiondata.toBooleanList(4);
  }

  void _toggleButton(int index) {
    setState(() {
      // Toggle state and update the model
      isSelected[index] = !isSelected[index];
      pescriptiondata.setToggle(index, isSelected[index]);

      print("Updated BitField: ${pescriptiondata.freqBitField.toRadixString(2)}"); // Debug
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return 
    
    Container
    (
      padding:const EdgeInsets.all(10),
      //margin: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
      decoration: BoxDecoration(
        
        color:Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.3),
               blurRadius: 10,
          offset: Offset.zero),
          ],

      ),
      child :     Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        
        children: [
      
      const Text('Frequency', textAlign: TextAlign.left,),
      
      
      
      ToggleButtons(
  // list of booleans
  isSelected: isSelected,
  // text color of selected toggle
  selectedColor: Colors.white,
  // text color of not selected toggle
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
    padding: EdgeInsets.symmetric(horizontal: 5),
    child: Text('Morning', style: TextStyle(fontSize: 18)),
  ),
  Padding(
    padding: EdgeInsets.symmetric(horizontal: 12),
    child: Text('Afternoon', style: TextStyle(fontSize: 18)),
  ),
  Padding(
    padding: EdgeInsets.symmetric(horizontal: 12),
    child: Text('Evening', style: TextStyle(fontSize: 18)),
  ),
  Padding(
    padding: EdgeInsets.symmetric(horizontal: 12),
    child: Text('Night', style: TextStyle(fontSize: 18)),
  ),],
  onPressed: _toggleButton,
// to select or deselect when pressed
  // onPressed: (int newIndex) { 
  //   final isOneSelected = isSelected.where((element) => element).length == 1;
  //   if (isOneSelected && isSelected[newIndex]) return;
  //   setState(() {
  //   // looping through the list of booleans values
  //   for (int index = 0; index < isSelected.length; index++) {
  //     // checking for the index value
  //     if (index == newIndex) {
  //       // one button is always set to true
  //       // toggle between the old index and new index value
  //     isSelected[index] = !isSelected[index];
  //     }
  //   }
  // });}
),


    ],));
  }

}