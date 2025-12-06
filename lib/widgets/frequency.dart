import 'package:docautomations/common/appcolors.dart';
import 'package:docautomations/datamodels/prescriptionData.dart';
import 'package:flutter/material.dart';

class FrequencyWidget extends StatefulWidget {
  final Prescriptiondata prescription; // Accept prescription as input
  final GlobalKey<FormFieldState<bool>> freqFieldKey;

  const FrequencyWidget({
    super.key,
    required this.freqFieldKey,
    required this.prescription,
  });

  @override
  State<FrequencyWidget> createState() => FrequencyWidgetState();
}

class FrequencyWidgetState extends State<FrequencyWidget> {
  late List<bool> isSelected;
  String? _errorText;
  @override
  void initState() {
    super.initState();
    isSelected = widget.prescription.toBooleanList(4);
  }

  void _toggleButton(int index) {
    setState(() {
      isSelected[index] = !isSelected[index];
      widget.prescription.setToggle(index, isSelected[index]);

      // print("Updated BitField: ${widget.prescription.freqBitField!=null?
      //   widget.prescription.freqBitField.toRadixString(2):''}"); // Debug
    });
  }

  bool validateFrequencySelection() {

    final isValid = isSelected.contains(true);
  setState(() {
    _errorText = isValid ? null : 'Please select at least one frequency.';
  });
  return isValid;
  // if (isSelected.contains(true)) {
  //   // At least one selected -> valid
  //   return true;
  // } else {
  //   // None selected -> show warning
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(
  //       content: Text('Please select at least one frequency (Morning/Afternoon/Evening/Night).'),
  //     ),
  //   );
  //   return false;
  // }
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
        const Text("Frequency", textAlign: TextAlign.left),

        // ----------------------------
        // 🔥 WRAPPED TOGGLE INTO FormField
        // ----------------------------
        FormField<bool>(
          key: widget.freqFieldKey,

          validator: (value) {
            if (!isSelected.contains(true)) {
              return "Please select at least one frequency";
            }
            return null;
          },

          builder: (field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ToggleButtons(
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

                    // ⚡ IMPORTANT: call didChange() to trigger validation updates
                    onPressed: (index) {
                      _toggleButton(index);
                      field.didChange(true);
                    },

                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Text('Morning', style: TextStyle(fontSize: 15)),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('Afternoon', style: TextStyle(fontSize: 15)),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('Evening', style: TextStyle(fontSize: 15)),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('Night', style: TextStyle(fontSize: 15)),
                      ),
                    ],
                  ),
                ),

                // ------------------------
                // 🔥 AUTOMATIC ERROR TEXT
                // ------------------------
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      field.errorText!,
                      style: _effectiveErrorStyle(context),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    ),
  );

  
}

TextStyle _effectiveErrorStyle(BuildContext context) {
  final theme = Theme.of(context);

  // Try to get the same error style used by TextFormField
  final baseErrorStyle = theme.inputDecorationTheme.errorStyle;

  // Fallback error color
  final red = theme.colorScheme.error;

  return TextStyle(
    fontSize: baseErrorStyle?.fontSize ?? 11,
    fontWeight: FontWeight.normal, // ensure NOT bold
    color: baseErrorStyle?.color ?? Color.fromARGB(255, 165, 5, 5),
    fontFamily: baseErrorStyle?.fontFamily 
        ?? theme.textTheme.bodyMedium?.fontFamily 
        ?? 'Merriweather_regular',
  );
}


  // @override
  // Widget build(BuildContext context) {
  //   return Container(
  //     padding: const EdgeInsets.all(10),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(10),
  //       boxShadow: [
  //         BoxShadow(
  //           color: AppColors.secondary.withOpacity(0.3),
  //           blurRadius: 10,
  //           offset: Offset.zero,
  //         ),
  //       ],
  //     ),
  //     child: Column(
       
  //       crossAxisAlignment: CrossAxisAlignment.stretch,
  //       children: [
           
  //         const Text('Frequency',  textAlign: TextAlign.left),
  //          FittedBox(
  //           fit: BoxFit.scaleDown, // shrink if needed
  // child:          ToggleButtons(
  //            key: widget.freqFieldKey,
  //           isSelected: isSelected,
  //           selectedColor: Colors.white,
  //           color: Colors.blue,
  //           fillColor: Colors.lightBlue.shade900,
  //           splashColor: Colors.red,
  //           highlightColor: Colors.orange,
  //           textStyle: const TextStyle(fontWeight: FontWeight.bold),
  //           renderBorder: true,
  //           borderColor: Colors.black,
  //           borderWidth: 1.5,
  //           borderRadius: BorderRadius.circular(10),
  //           selectedBorderColor: Colors.pink,            
  //           onPressed: _toggleButton,
  //           children: const [
  //             Padding(
  //               padding: EdgeInsets.symmetric(horizontal: 5),
  //               child: Text('Morning', style: TextStyle(fontSize: 15)),
  //             ),
  //             Padding(
  //               padding: EdgeInsets.symmetric(horizontal: 12),
  //               child: Text('Afternoon', style: TextStyle(fontSize: 15)),
  //             ),
  //             Padding(
  //               padding: EdgeInsets.symmetric(horizontal: 12),
  //               child: Text('Evening', style: TextStyle(fontSize: 15)),
  //             ),
  //             Padding(
  //               padding: EdgeInsets.symmetric(horizontal: 12),
  //               child: Text('Night', style: TextStyle(fontSize: 15)),
  //             ),
  //           ],
  //         ),),
  //         if (_errorText != null)
  //           Padding(
  //             padding: const EdgeInsets.only(top: 8),
  //             child: Text(
  //               _errorText!,
  //               style: const TextStyle(color: Colors.red, fontSize: 14),
  //             ),
  //           ),
  //       ],
  //     ),
  //   );
  // }
}
