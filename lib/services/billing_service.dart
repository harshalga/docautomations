import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

class BillingService {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

    List<ProductDetails> products = [];

  Future<void> init(
      Function(PurchaseDetails purchase) onPurchaseSuccess) async {
    final available = await _iap.isAvailable();
    if (!available) throw Exception("Store not available");

    _subscription = _iap.purchaseStream.listen((purchases) {
      for (final purchase in purchases) {
        if (purchase.status == PurchaseStatus.error) {
   print("Purchase error: ${purchase.error}");
}
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          onPurchaseSuccess(purchase);
        }

        if (purchase.pendingCompletePurchase) {
          InAppPurchase.instance.completePurchase(purchase);
        }
      }
    });
  }

  Future<List<ProductDetails>> getProducts() async {
    const ids = {
      'prescriptor_pro_subscription',
    };

    final response = await _iap.queryProductDetails(ids);

    if (response.error != null) {
      throw Exception(response.error!.message);
    }

    //return response.productDetails;
    products = response.productDetails;

    return products;
  }

  // Future<void> buy(ProductDetails product) async {
  //   final purchaseParam = PurchaseParam(productDetails: product);
  //   await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  // }

  Future<void> buy(ProductDetails product, String offerToken) async {
  final purchaseParam = GooglePlayPurchaseParam(
    productDetails: product,
    offerToken: offerToken,
  );

  await _iap.buyNonConsumable(
    purchaseParam: purchaseParam,
  );
}

// Future<void> buySubscription(
//   ProductDetails product,
//   String offerToken,
// ) async {

//   final purchaseParam = GooglePlayPurchaseParam(
//     productDetails: product,
//     offerToken: offerToken,
//   );

//   await InAppPurchase.instance.buyNonConsumable(
//     purchaseParam: purchaseParam,
//   );
// }

  Future<void> restore() async {
    await _iap.restorePurchases();
  }

  void dispose() {
    _subscription?.cancel();
  }
}