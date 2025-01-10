import 'package:docautomations/common/appcolors.dart';
import 'package:flutter/material.dart';

class Instructions extends StatefulWidget
{
  const Instructions({super.key});
  @override
  State<Instructions> createState()=> InstructionsState();
  
}

class InstructionsState extends State<Instructions>   {

  final TextEditingController remarksController = TextEditingController();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    remarksController.dispose();
    
    super.dispose();
  }
  @override
  Widget build(Object context) {
    return Container(padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.3),blurRadius:10,
      offset: Offset.zero)],
    ),
    child:
    Row(
      children: [
      Expanded(child: TextField(
            controller: remarksController,
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 5,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            decoration:
                const InputDecoration(border: OutlineInputBorder(), labelText: 'Instructions'),
          ),)]
    ));
  }
}

