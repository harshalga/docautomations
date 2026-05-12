class ActivationResult {
  final bool success;
  final DateTime? expiryDate;
  final String? productId;

  ActivationResult({
    required this.success,
    this.expiryDate,
    this.productId,
  });
} 