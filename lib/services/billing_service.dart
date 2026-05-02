// import 'dart:async';
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:in_app_purchase_android/in_app_purchase_android.dart';

// class BillingService {
//   final InAppPurchase _iap = InAppPurchase.instance;
//   StreamSubscription<List<PurchaseDetails>>? _subscription;

//     List<ProductDetails> products = [];

//   Future<void> init(
//       Function(PurchaseDetails purchase) onPurchaseSuccess) async {
//     final available = await _iap.isAvailable();
//     if (!available) throw Exception("Store not available");

//     _subscription = _iap.purchaseStream.listen((purchases) {
//       for (final purchase in purchases) {
//         if (purchase.status == PurchaseStatus.error) {
//    print("Purchase error: ${purchase.error}");
// }
//         if (purchase.status == PurchaseStatus.purchased ||
//             purchase.status == PurchaseStatus.restored) {
//           onPurchaseSuccess(purchase);
//         }

//         if (purchase.pendingCompletePurchase) {
//           InAppPurchase.instance.completePurchase(purchase);
//         }
//       }
//     });
//   }

//   Future<List<ProductDetails>> getProducts() async {
//     const ids = {
//       'prescriptor_pro_subscription',
//     };

//     final response = await _iap.queryProductDetails(ids);

//     if (response.error != null) {
//       throw Exception(response.error!.message);
//     }

//     //return response.productDetails;
//     products = response.productDetails;

//     return products;
//   }

//   // Future<void> buy(ProductDetails product) async {
//   //   final purchaseParam = PurchaseParam(productDetails: product);
//   //   await _iap.buyNonConsumable(purchaseParam: purchaseParam);
//   // }

//   Future<void> buy(ProductDetails product, String offerToken) async {
//   final purchaseParam = GooglePlayPurchaseParam(
//     productDetails: product,
//     offerToken: offerToken,
//   );

//   await _iap.buyNonConsumable(
//     purchaseParam: purchaseParam,
//   );
// }

// // Future<void> buySubscription(
// //   ProductDetails product,
// //   String offerToken,
// // ) async {

// //   final purchaseParam = GooglePlayPurchaseParam(
// //     productDetails: product,
// //     offerToken: offerToken,
// //   );

// //   await InAppPurchase.instance.buyNonConsumable(
// //     purchaseParam: purchaseParam,
// //   );
// // }

//   Future<void> restore() async {
//     await _iap.restorePurchases();
//   }

//   void dispose() {
//     _subscription?.cancel();
//   }
// }


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

class BillingService {
  final InAppPurchase _iap =
      InAppPurchase.instance;

  StreamSubscription<
      List<PurchaseDetails>>? _subscription;

  List<ProductDetails> products = [];

  // =================================================
  // INIT
  // =================================================
  Future<void> init(
    Function(PurchaseDetails purchase)
        onPurchaseSuccess, {
    VoidCallback? onError,
    VoidCallback? onCancelled,
    VoidCallback? onPending,
  }) async {

    final available =
        await _iap.isAvailable();

    if (!available) {
      throw Exception(
          "Store not available");
    }

    _subscription =
        _iap.purchaseStream.listen(
      (purchases) {

        for (final purchase
            in purchases) {

          print(
            "Purchase Status: ${purchase.status}",
          );

          // ---------------------------------
          // SUCCESS
          // ---------------------------------
          if (purchase.status ==
                  PurchaseStatus
                      .purchased ||
              purchase.status ==
                  PurchaseStatus
                      .restored) {

            onPurchaseSuccess(
                purchase);
          }

          // ---------------------------------
          // PENDING
          // ---------------------------------
          else if (purchase.status ==
              PurchaseStatus
                  .pending) {

            if (onPending !=
                null) {
              onPending();
            }
          }

          // ---------------------------------
          // ERROR
          // ---------------------------------
          else if (purchase.status ==
              PurchaseStatus
                  .error) {

            print(
              "Purchase Error: ${purchase.error}",
            );

            if (onError !=
                null) {
              onError();
            }
          }

          // ---------------------------------
          // CANCELLED
          // ---------------------------------
          else if (purchase.status ==
              PurchaseStatus
                  .canceled) {

            if (onCancelled !=
                null) {
              onCancelled();
            }
          }

          // ---------------------------------
          // COMPLETE PURCHASE
          // ---------------------------------
          if (purchase
              .pendingCompletePurchase) {
            _iap.completePurchase(
                purchase);
          }
        }
      },
      onError: (e) {
        print(
          "Purchase Stream Error: $e",
        );

        if (onError != null) {
          onError();
        }
      },
    );
  }

  // =================================================
  // PRODUCTS
  // =================================================
  Future<List<ProductDetails>>
      getProducts() async {

    const ids = {
      'prescriptor_pro_subscription',
    };

    final response =
        await _iap
            .queryProductDetails(
                ids);

    if (response.error != null) {
      throw Exception(
          response.error!.message);
    }

    products =
        response.productDetails;

    return products;
  }

  // =================================================
  // BUY
  // =================================================
  Future<void> buy(
    ProductDetails product,
    String offerToken,
  ) async {

    final purchaseParam =
        GooglePlayPurchaseParam(
      productDetails: product,
      offerToken: offerToken,
    );

    await _iap.buyNonConsumable(
      purchaseParam:
          purchaseParam,
    );
  }

  // =================================================
  // RESTORE
  // =================================================
  Future<void> restore() async {
    await _iap
        .restorePurchases();
  }

  // =================================================
  // DISPOSE
  // =================================================
  void dispose() {
    _subscription?.cancel();
  }
}