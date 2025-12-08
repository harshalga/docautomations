// import 'dart:io';
// import 'dart:typed_data';
// import 'package:docautomations/common/appcolors.dart';
// import 'package:docautomations/widgets/AddPrescription.dart';
// import 'package:docautomations/widgets/AddPrescriptionScr.dart';
// import 'package:flutter/material.dart';
// import 'package:printing/printing.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:path_provider/path_provider.dart';

// class PrintPreviewScreen extends StatefulWidget {
//   final Uint8List pdfBytes; // The generated PDF bytes
//   const PrintPreviewScreen({super.key, required this.pdfBytes});

//   @override
//   State<PrintPreviewScreen> createState() => _PrintPreviewScreenState();
// }

// class _PrintPreviewScreenState extends State<PrintPreviewScreen> {
//   bool _isSharing = false;

//   Future<void> _sharePdf() async {
//     setState(() => _isSharing = true);
//     try {
//       final dir = await getTemporaryDirectory();
//       final file = File('${dir.path}/prescription_preview.pdf');
//       await file.writeAsBytes(widget.pdfBytes);
//       await Share.shareXFiles([XFile(file.path)], text: 'Prescription from Prescriptor');
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error sharing PDF: $e")),
//       );
//     } finally {
//       setState(() => _isSharing = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Use scaffoldBackgroundColor so it matches the app theme if AppColors doesn't define background
//    // final background = Theme.of(context).scaffoldBackgroundColor;
//     return Scaffold(
//       backgroundColor:AppColors.background,
//       appBar: AppBar(
//         backgroundColor: AppColors.secondary,
//         title:  Text(
//           "Prescriptor",
//           //style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
//           style: Theme.of(context).textTheme.titleLarge!.copyWith(
//                         color: Theme.of(context).colorScheme.onSecondary,),
//         ),
//         centerTitle: true,
//         elevation: 5,
//       ),
//       body: Column(
//         children: [
//           // 🔹 Subtitle Bar
//           Container(
//             color: AppColors.colorDarkPrimary,
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   "Print Preview",
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                   ),
//                 ),
//                 IconButton(
//                   icon: _isSharing
//                       ? const CircularProgressIndicator()
//                       : const Icon(Icons.share, color: Colors.blueAccent),
//                   onPressed: _isSharing ? null : _sharePdf,
//                   tooltip: "Share PDF",
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 8),

//           // 🔹 PDF Preview Area
//           Expanded(
//             child: Container(
//               margin: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(30),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.primary.withOpacity(0.25),
//                     blurRadius: 15,
//                     offset: Offset.zero,
//                   ),
//                 ],
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(30),
//                 child: PdfPreview(
//                   build: (format) async => widget.pdfBytes,
//                   canChangePageFormat: false,
//                   canChangeOrientation: false,
//                   allowSharing: false,
//                   allowPrinting: false,
//                 ),
//               ),
//             ),
//           ),

//           // 🔹 Bottom Buttons
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 ElevatedButton.icon(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.grey.shade400,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 24, vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   onPressed: () {
//                     Navigator.pop(context);
//                     // Navigator.pushReplacement(
//                     //   context,
//                     //   MaterialPageRoute(
//                     //     builder: (context) => const Addprescriptionscr(),
//                     //   ),
//                     //);
//                   },
//                   icon: const Icon(Icons.arrow_back_ios_new),
//                   label: const Text("Back", style: TextStyle( color: Colors.black,)),
//                 ),
//                 ElevatedButton.icon(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueAccent,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 24, vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
                      
//                     ),
//                   ),
//                   onPressed: () async {
//                     await Printing.layoutPdf(
//                         onLayout: (format) async => widget.pdfBytes);
//                   },
//                   icon: const Icon(Icons.print),
//                   label: const Text("Print",style: TextStyle( color: Colors.white,)),
                  
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'dart:io';
import 'dart:typed_data';
import 'package:docautomations/common/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class PrintPreviewScreen extends StatefulWidget {
  final Uint8List pdfBytes; // The generated PDF bytes
  const PrintPreviewScreen({super.key, required this.pdfBytes});

  @override
  State<PrintPreviewScreen> createState() => _PrintPreviewScreenState();
}

class _PrintPreviewScreenState extends State<PrintPreviewScreen> {
  bool _isSharing = false;

  Future<void> _sharePdf() async {
    setState(() => _isSharing = true);
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/prescription_preview.pdf');
      await file.writeAsBytes(widget.pdfBytes);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Prescription from Prescriptor',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sharing PDF: $e")),
      );
    } finally {
      setState(() => _isSharing = false);
    }
  }

  // 🔹 Helper Widget for PDF Preview Area
  Widget buildPreviewContent() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 15,
            offset: Offset.zero,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: PdfPreview(
          build: (format) async => widget.pdfBytes,
          canChangePageFormat: false,
          canChangeOrientation: false,
          allowSharing: false,
          allowPrinting: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: Text(
          "Prescriptor",
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSecondary,
              ),
        ),
        centerTitle: true,
        elevation: 5,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 🔹 Subtitle Bar
              Container(
                color: AppColors.colorDarkPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Print Preview",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: _isSharing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.share, color: Colors.blueAccent),
                      onPressed: _isSharing ? null : _sharePdf,
                      tooltip: "Share PDF",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // 🔹 PDF Preview
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: buildPreviewContent(),
              ),

              // 🔹 Buttons (Back / Print)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade400,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new),
                      label: const Text(
                        "Back",
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        await Printing.layoutPdf(
                            onLayout: (format) async => widget.pdfBytes);
                      },
                      icon: const Icon(Icons.print),
                      label: const Text(
                        "Print",
                        style: TextStyle(color: Colors.black , fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

  
