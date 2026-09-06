class OperationResult {

  //===========================================================================
  // Properties
  //===========================================================================

  final bool success;

  final String message;

  final dynamic data;


  //===========================================================================
  // Constructor
  //===========================================================================

  const OperationResult._({

    required this.success,

    required this.message,

    this.data,

  });


  //===========================================================================
  // Success
  //===========================================================================

  factory OperationResult.success(

    String message, {

    dynamic data,

  }) {

    return OperationResult._(

      success: true,

      message: message,

      data: data,

    );

  }


  //===========================================================================
  // Failure
  //===========================================================================

  factory OperationResult.failure(

    String message, {

    dynamic data,

  }) {

    return OperationResult._(

      success: false,

      message: message,

      data: data,

    );

  }

}