import 'arculus_error.dart';

/// Generic result wrapper for Arculus SDK operations
class ArculusResult<T> {
  final T? data;
  final ArculusError? error;
  final bool isSuccess;

  const ArculusResult._({
    this.data,
    this.error,
    required this.isSuccess,
  });

  /// Create a successful result
  factory ArculusResult.success(T data) {
    return ArculusResult._(
      data: data,
      isSuccess: true,
    );
  }

  /// Create a failure result
  factory ArculusResult.failure(ArculusError error) {
    return ArculusResult._(
      error: error,
      isSuccess: false,
    );
  }

  /// Check if the operation was successful
  bool get isFailure => !isSuccess;

  /// Get the data if successful, otherwise throw the error
  T get value {
    if (isSuccess && data != null) {
      return data!;
    }
    throw error ?? ArculusError(code: -1, message: 'Unknown error');
  }
}
