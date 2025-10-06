import 'package:docautomations/common/licenseprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';


/// Simple paywall placeholder
class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});


  String getPlatform() {
  if (Platform.isAndroid) return "android";
  if (Platform.isIOS) return "ios";
  return "unknown";
}

 Future<void> purchase(BuildContext context,String productId) async 
  {
        final platform = getPlatform();

     

                // TODO: integrate with in_app_purchase
                await context.read<LicenseProvider>().activateSubscription(
                      productId,
                      "txn_dummy",
                      DateTime.now().add(const Duration(days: 30)),
                      platform,
                      "token_IOS_dummy",
                    );

  }
  @override
  Widget build(BuildContext context) {
    final license = context.watch<LicenseProvider>();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Your free trial has ended."),
            ElevatedButton(
              onPressed: () async {

                purchase(context,"prescriptor_monthly");
              },
              child: const Text("₹149 / month"),
            ),


            ElevatedButton(
              onPressed: () async {

                purchase(context,"prescriptor_yearly");
              },
              child: const Text("₹1599 / year"),
            ),

          ],
        ),
      ),
    );
  }
}