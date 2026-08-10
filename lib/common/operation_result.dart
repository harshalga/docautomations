class OperationResult {

     final bool success;

     final String message;

//---------------------------------------------------------------------------
  // Constructor
  //---------------------------------------------------------------------------

  const OperationResult({
    required this.success,
    this.message = '',
  });

     //---------------------------------------------------------------------------
  // Factory Methods
  //---------------------------------------------------------------------------

  factory OperationResult.success([
    String message = '',
  ]) {
    return OperationResult(
      success: true,
      message: message,
    );
  }

  factory OperationResult.failure(
    String message,
  ) {
    return OperationResult(
      success: false,
      message: message,
    );
  }


}