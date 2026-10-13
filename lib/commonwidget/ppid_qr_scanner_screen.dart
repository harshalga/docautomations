

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class PpidQrScannerScreen extends StatefulWidget {
  const PpidQrScannerScreen({super.key});

  @override
  State<PpidQrScannerScreen> createState() =>
      _PpidQrScannerScreenState();
}

//=============================================================================
// PPID QR SCANNER STATE
//=============================================================================

class _PpidQrScannerScreenState
    extends State<PpidQrScannerScreen> {

  final MobileScannerController _scannerController =
      MobileScannerController();


  bool _hasScanned = false;


  @override
  void dispose() {

    _scannerController.dispose();

    super.dispose();
  }


  //-------------------------------------------------------------------------
  // HANDLE SCAN
  //-------------------------------------------------------------------------

  void _handleBarcode(
    BarcodeCapture capture,
  ) {

    if (_hasScanned) {
      return;
    }


    for (final barcode in capture.barcodes) {

      final value =
          barcode.rawValue?.trim();


      if (value == null ||
          value.isEmpty) {

        continue;
      }


      _hasScanned = true;


      _scannerController.stop();


      Navigator.of(context).pop(
        value,
      );


      return;
    }
  }


  //-------------------------------------------------------------------------
  // BUILD
  //-------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {

    final theme =
        Theme.of(context);


    return Scaffold(

      appBar:
          AppBar(

        title:
            const Text(
          'Scan Patient QR Code',
        ),
      ),


      body:
          Stack(

        fit:
            StackFit.expand,

        children: [

          MobileScanner(

            controller:
                _scannerController,

            onDetect:
                _handleBarcode,
          ),


          //===================================================================
          // SCANNER OVERLAY
          //===================================================================

          Center(

            child:
                Container(

              width:
                  270,

              height:
                  180,

              decoration:
                  BoxDecoration(

                border:
                    Border.all(
                  color:
                      theme.colorScheme.primary,
                  width:
                      3,
                ),

                borderRadius:
                    BorderRadius.circular(16),
              ),
            ),
          ),


          //===================================================================
          // INSTRUCTION
          //===================================================================

          Positioned(

            left:
                24,

            right:
                24,

            bottom:
                48,

            child:
                Container(

              padding:
                  const EdgeInsets.all(16),

              decoration:
                  BoxDecoration(

                color:
                    Colors.black.withValues(
                  alpha: 0.70,
                ),

                borderRadius:
                    BorderRadius.circular(14),
              ),


              child:
                  const Text(

                'Place the patient QR code inside the frame.',

                textAlign:
                    TextAlign.center,

                style:
                    TextStyle(
                  color:
                      Colors.white,

                  fontSize:
                      15,

                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}