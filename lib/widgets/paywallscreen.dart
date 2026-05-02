import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:docautomations/commonwidget/loadingOverlay.dart';
import 'package:docautomations/services/auth_service.dart';
import 'package:docautomations/services/billing_service.dart';
import 'package:docautomations/services/license_api_service.dart';
import 'package:docautomations/utils/subscriptionplan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:docautomations/common/licenseprovider.dart'; // ✅ make sure this import is correct
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';









class PaywallScreen extends StatefulWidget {
  final VoidCallback onSubscriptionActivated;//  onPurchaseSuccess;
  final VoidCallback onMaybeLater;
  final VoidCallback onRestorePurchase;   // NEW
  final VoidCallback onSwitchDoctor;      // NEW

  const PaywallScreen({super.key, required this.onSubscriptionActivated, 
  required this.onMaybeLater,
  required this.onRestorePurchase,
    required this.onSwitchDoctor,});
  @override
  State<PaywallScreen> createState() => _PaywallScreenState();

}

class _PaywallScreenState extends State<PaywallScreen> {
  late BillingService billingService;
  List<GooglePlayProductDetails> products = [];
bool isBillingLoading = true;
  
  //onPurchaseSuccess
  //final
   bool _isPurchasing = false;
  
  int selectedOption = -1;//0; // 0: none, 1: 12 months, 2: 1 month
 
  //bool isLoading = true;

  TextEditingController feedbackController = TextEditingController();
  bool feedbackSaved = false;
 

  @override
void initState() {
  super.initState();

  billingService = BillingService();

  billingService.init(_handlePurchaseSuccess,onError: _handlePurchaseFailure,);

  Future.microtask(() async {
//Added token check before loading products to prevent unnecessary API calls if user is already logged out
    final token =
        await AuthService.getToken();

    if (token == null) {
      widget.onSwitchDoctor();
      return;
    }


    loadProducts();
  });

  
}


List<SubscriptionPlan> getSubscriptionPlans() {
  final offers = getOffers();

  return offers.map<SubscriptionPlan>((offer) {
    if (offer.pricingPhases.isEmpty) {
      return SubscriptionPlan(
        basePlanId: offer.basePlanId ?? "",
        price: "Unavailable",
        billingPeriod: "",
        offerToken: offer.offerIdToken ?? "",
      );
    }

    final pricing = offer.pricingPhases.first;

    return SubscriptionPlan(
      basePlanId: offer.basePlanId ?? "",
      price: pricing.formattedPrice,
      billingPeriod: pricing.billingPeriod,
      offerToken: offer.offerIdToken ?? "",
    );
  }).toList();
}






List<dynamic> getOffers() {
  
  if (products.isEmpty) return [];

  final product = products.first;

  return product.productDetails.subscriptionOfferDetails ?? [];
}






Future<void> loadProducts() async {
  try {

    final result = await billingService.getProducts();

    products = result
        .whereType<GooglePlayProductDetails>()
        .toList();

    print("Products loaded: ${products.length}");

  } catch (e) {

    print("Billing error: $e");

  } finally {

    if (mounted) {
      setState(() => isBillingLoading = false);
    }

  }
}

  
  String getPlatform() {
    if (Theme.of(context).platform == TargetPlatform.android) return "android";
    if (Theme.of(context).platform == TargetPlatform.iOS) return "ios";
    return "unknown"; //Bydefault we save android as the platform
  }


void _handlePurchaseFailure() {
  if (!mounted) return;

  setState(() {
    _isPurchasing = false;
  });
}

Future<void> _handlePurchaseSuccess(PurchaseDetails purchase) async {
if(!mounted) return;
print("Purchase success callback triggered");
  print("Product: ${purchase.productID}");
  print("Status: ${purchase.status}");
  

  final token =
      purchase.verificationData.serverVerificationData;
bool success = false;
  try{
   success = await LicenseApiService.activateSubscription(
    purchase.productID,
    purchase.purchaseID ?? "",
    //null,
    getPlatform(),
    token,
  );
   } catch (_) {
    success = false;
  }
  // If token expired → refresh & retry
  if (!success) {

    final refreshed =
        await AuthService
            .refreshAccessToken();

    if (refreshed) {
    try{
      success =
          await LicenseApiService
              .activateSubscription(
        purchase.productID,
        purchase.purchaseID ?? "",
        getPlatform(),
        token,
      );
    } catch (_) {
      success = false;
    }
    }
  }


  if (!mounted) return;

  if (success) {

  //   if (mounted) {
  //   setState(() {
  //     _isPurchasing = false;
  //   });
  // }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      backgroundColor: Colors.green,
      content: Text(        
        "Subscription activated successfully",
      ),
      duration: Duration(seconds: 2),
    ),
  );

  await Future.delayed(
    const Duration(seconds: 1),
  );

  if (!mounted) return;

  widget.onSubscriptionActivated();
}else {
if (mounted) {
    setState(() {
      _isPurchasing = false;
    });
  }
    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Payment received. Activation syncing..."
        ),
      ),
    );
  }

}



Future<void> _purchase() async {

  if (products.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Subscription unavailable")),
    );
    return;
  }

  try {

    setState(() {
      _isPurchasing = true;
    //  isLoading = true;
    });
    final plans = getSubscriptionPlans();
    if (plans.isEmpty) return;
    final selectedPlan = plans[selectedOption];

    final product = products.first;

    await billingService.buy(product,selectedPlan.offerToken);

  } catch (e) {

    print("Purchase error: $e");

  } finally {

    // if (mounted) {
    //   setState(() {
    //     _isPurchasing = false;
    //    // isLoading = false;
    //   });
    // }

  }
}
  

  Future<void> confirmExit() async {
    final platform = getPlatform();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exit App"),
        content: const Text("Are you sure you want to exit?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (result == true) {
      print("inside result $result");
      if (kIsWeb) {
        print("inside kisweb");
        // Web: just show message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You can now close the browser tab.")),
        );
      } else if (platform== 'android') {
          SystemNavigator.pop();
        } else if (platform=='ios') {
          exit(0);
        }
    }
  }
  Future<void> _saveFeedback(BuildContext context, String feedback) async {
    
    if (feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter your feedback before submitting.")),
      );
      return;
    }
    
//setState(() => isLoading = true);
    // TODO: save feedback to backend with doctorId
    //storeFeedbackBeforeUninstall
    final licenseProvider = context.read<LicenseProvider>();
    await licenseProvider.saveFeedback(feedback);

    print("Feedback submitted: ${feedbackController.text}");


    

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Thank you for your feedback!")),
    );
    if (mounted) {
      setState(() {
        //isLoading = false;
        feedbackSaved = true;
      });
    }
  }
 


  @override
  Widget build(BuildContext context) {
    //final license = context.watch<LicenseProvider>();
    //final licenseProvider = Provider.of<LicenseProvider>(context);
    //final licenseProvider = context.read<LicenseProvider>();


//     if (isBillingLoading) {
//   return const Scaffold(
//     body: Center(child: CircularProgressIndicator()),
//   );
// }

     final plans = getSubscriptionPlans();

   

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),

              // App Logo
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
                    'assets/icon/app_logo.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                "Your trial period has expired!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              Text(
                "Hope Prescriptor served you well.\nWe would love to hear your feedback. \nEither email at contactprescriptor@zohomail.in  or type in below...",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),

              // Feedback Box
              TextField(
                controller: feedbackController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Share your thoughts here...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 10),

              // Submit Feedback Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:()=> _saveFeedback(context,feedbackController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    feedbackSaved ? "Feedback Submitted ✓" : "Submit Feedback",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              const Text(
                "Following are our plans you can subscribe to\nfor activating Prescriptor:",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 20),

              
 // ⭐ Small loader while billing products load
if (isBillingLoading)
  const Padding(
    padding: EdgeInsets.symmetric(vertical: 20),
    child: Column(
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 10),
        Text(
          "Loading subscription plans...",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    ),
  )
else
             

Column(
  children: plans.asMap().entries.map((entry) {
    final index = entry.key;
    final plan = entry.value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _subscriptionCard(
        title: plan.basePlanId,
        // totalPrice: 0,
        // perMonth: 0,
        priceLabel: plan.price,
        isBestSeller: plan.basePlanId == "yearly-plan",
        isSelected: selectedOption == index,
        onTap: () {
          setState(() {
            selectedOption = index;
          });
        },
      ),
    );
  }).toList(),
),
              const SizedBox(height: 30),

              // Activate Subscription Button
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: (selectedOption == -1 || isBillingLoading || _isPurchasing)//0
                      ? null
                      : () async {
                          // if (selectedOption == 1) {
                          //   //TODO: pass actual productId based on selection
                          //   await _purchase(context, "prescriptor_yearly");
                          // } else {
                          //   await  _purchase(context, "prescriptor_monthly");
                          // }
                          await _purchase();
                        },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    padding: EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient:(selectedOption == -1 ||  isBillingLoading ||  _isPurchasing)
                          ? LinearGradient(colors: [Colors.grey, Colors.grey.shade400])
                          : LinearGradient(colors: [Colors.blueAccent, Colors.lightBlueAccent]),
                      boxShadow: selectedOption == 0
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.3),
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                            ],
                    ),
                    child: Center(
                      child: Text(
                        'Activate Subscription',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

SizedBox(
  width: double.infinity,
  child: TextButton(
    //onPressed: widget.onRestorePurchase,
    onPressed: () async {
  await billingService.restore();
},
    child: const Text(
      "Restore Purchase",
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
),

SizedBox(
  width: double.infinity,
  child: TextButton(
    onPressed: widget.onSwitchDoctor,
    child: const Text(
      "Switch Doctor (Log out)",
      style: TextStyle(
        color: Colors.red,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
),

              const SizedBox(height: 16),

              // Maybe Later Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: (){
                     // Call a callback that tells parent (AppEntryPoint)
                     
                    widget.onMaybeLater();
                   }, //async => await confirmExit(),
                  child: Text(
                    "Maybe Later",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
        /// Reusable overlay
        // ✅ Overlay Loader when loading
// if (isLoading)
//     LoadingOverlay(isLoading:isLoading, message: "loading...."),

if (_isPurchasing)
  LoadingOverlay(
    isLoading: true,
    message: "Activating subscription...",
  ),


        ],)
      ),
    );
  }

  Widget _subscriptionCard({
    required String title,
      required String priceLabel,
      required bool isBestSeller,
      required bool isSelected,
     required VoidCallback onTap,
    // required double totalPrice,
    // required double perMonth,
    // required bool isBestSeller,
    // required bool isSelected,
    // required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      if (isBestSeller)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Colors.orange, Colors.deepOrange]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Best Seller',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                   
                    priceLabel,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: isSelected,
              onChanged: (_) => onTap(),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              activeColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
