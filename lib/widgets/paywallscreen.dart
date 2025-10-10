import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:docautomations/commonwidget/loadingOverlay.dart';
import 'package:docautomations/services/license_api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:docautomations/common/licenseprovider.dart'; // ✅ make sure this import is correct
import 'package:flutter/services.dart';


class PaywallScreen extends StatefulWidget {
  final VoidCallback onSubscriptionActivated;//  onPurchaseSuccess;
  final VoidCallback onMaybeLater;
  const PaywallScreen({super.key, required this.onSubscriptionActivated, required this.onMaybeLater});
  @override
  State<PaywallScreen> createState() => _PaywallScreenState();

}

class _PaywallScreenState extends State<PaywallScreen> {
  //onPurchaseSuccess
  bool _isPurchasing = false;
  
  int selectedOption = 0; // 0: none, 1: 12 months, 2: 1 month
  String currency = 'INR';
  double exchangeRate = 1.0;
  double basePrice12M = 1599; // Base INR price
  double basePrice1M = 149;   // Base INR price
  bool isLoading = true;

  TextEditingController feedbackController = TextEditingController();
  bool feedbackSaved = false;
 

  @override
  void initState() {
    super.initState();
    _initCurrency();
  }

  Future<void> _initCurrency() async {
    try {
      currency = _getDeviceCurrency();
      exchangeRate = await _fetchExchangeRate(currency);
    } catch (e) {
      print("error $e");
      exchangeRate = 1.0;
      currency = 'INR';
    }
      if (mounted) setState(() => isLoading = false);
  }

  String _getDeviceCurrency() {
    final locale = ui.PlatformDispatcher.instance.locale;
    final countryCode = locale.countryCode ?? 'IN';

    Map<String, String> countryCurrency = {
      'IN': 'INR',
      'US': 'USD',
      'GB': 'GBP',
      'EU': 'EUR',
      'CA': 'CAD',
      'AU': 'AUD',
      'SG': 'SGD',
      'JP': 'JPY',
      'AE': 'AED',
    };

    return countryCurrency[countryCode] ?? 'INR';
  }

  Future<double> _fetchExchangeRate(String currency) async {
    final response = await http.get(Uri.parse('https://api.exchangerate-api.com/v4/latest/INR'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['rates'][currency] ?? 1.0;
    } else {
      throw Exception('Failed to fetch INR-based exchange rate');
    }
  }

  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(
      name: currency,
      symbol: NumberFormat.simpleCurrency(name: currency).currencySymbol,
      decimalDigits: 2,
    );
    return format.format(amount);
  }

  String getPlatform() {
    if (Theme.of(context).platform == TargetPlatform.android) return "android";
    if (Theme.of(context).platform == TargetPlatform.iOS) return "ios";
    return "unknown"; //Bydefault we save android as the platform
  }

  Future<void> _purchase(BuildContext context, String productId) async {

          if (_isPurchasing) return;
          setState((){
      _isPurchasing = true;
      isLoading = true;
          } );
    bool success= false;
    final platform = getPlatform();
    
    //final licenseProvider = context.read<LicenseProvider>();

    
    try{

    final expiryDate = DateTime.now().add(
      Duration(days: productId == "prescriptor_yearly" ? 365 : 30),
    );

    success = await LicenseApiService.activateSubscription(
      productId,
      "txn_dummy",
      expiryDate,
      platform,
      "token_dummy"
    );
     if (!mounted) return; // 👈 avoids accessing context after dispose
    
    if (success)
    {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subscription activated!')));
      // ✅ Notify parent (AppEntryPoint)
      widget.onSubscriptionActivated();

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase failed. Please try again.')),
      );
    }

    if (mounted) setState(() => _isPurchasing = false);
      
    } catch (e) {


      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
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
    
setState(() => isLoading = true);
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
        isLoading = false;
        feedbackSaved = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //final license = context.watch<LicenseProvider>();
    //final licenseProvider = Provider.of<LicenseProvider>(context);
    //final licenseProvider = context.read<LicenseProvider>();

    

    double price12M = double.parse((basePrice12M * exchangeRate).toStringAsFixed(2));
    double price1M = double.parse((basePrice1M * exchangeRate).toStringAsFixed(2));
    double perMonth12M = double.parse((price12M / 12).toStringAsFixed(2));

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
                "Hope Prescriptor served you well.\nWe would love to hear your feedback. \nEither email at vhsystemautomations@gmail.com or type in below...",
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

              // 12-month Option
              _subscriptionCard(
                title: '12 Months',
                totalPrice: price12M,
                perMonth: perMonth12M,
                isBestSeller: true,
                isSelected: selectedOption == 1,
                onTap: () => setState(() => selectedOption = 1),
              ),
              const SizedBox(height: 16),

              // 1-month Option
              _subscriptionCard(
                title: '1 Month',
                totalPrice: price1M,
                perMonth: price1M,
                isBestSeller: false,
                isSelected: selectedOption == 2,
                onTap: () => setState(() => selectedOption = 2),
              ),
              const SizedBox(height: 30),

              // Activate Subscription Button
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: selectedOption == 0
                      ? null
                      : () async {
                          if (selectedOption == 1) {
                            await _purchase(context, "prescriptor_yearly");
                          } else {
                            await  _purchase(context, "prescriptor_monthly");
                          }
                        },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    padding: EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: selectedOption == 0
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
if (isLoading)
    LoadingOverlay(isLoading:isLoading, message: "loading...."),
        ],)
      ),
    );
  }

  Widget _subscriptionCard({
    required String title,
    required double totalPrice,
    required double perMonth,
    required bool isBestSeller,
    required bool isSelected,
    required VoidCallback onTap,
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
                    '${_formatCurrency(totalPrice)} • (${_formatCurrency(perMonth)}/month)',
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
