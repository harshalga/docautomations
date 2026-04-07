class SubscriptionPlan {
  final String basePlanId;
  final String price;
  final String billingPeriod;
  final String offerToken;

  SubscriptionPlan({
    required this.basePlanId,
    required this.price,
    required this.billingPeriod,
    required this.offerToken,
  });
}