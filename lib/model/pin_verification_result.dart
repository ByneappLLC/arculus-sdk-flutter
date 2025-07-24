/// Result of PIN verification operation
class PinVerificationResult {
  final bool isValid;
  final int remainingTries;

  const PinVerificationResult({
    required this.isValid,
    required this.remainingTries,
  });

  /// Create from map response
  factory PinVerificationResult.fromMap(Map<String, dynamic> map) {
    return PinVerificationResult(
      isValid: map['isValid'] as bool,
      remainingTries: map['remainingTries'] as int,
    );
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'isValid': isValid,
      'remainingTries': remainingTries,
    };
  }

  @override
  String toString() {
    return 'PinVerificationResult(isValid: $isValid, remainingTries: $remainingTries)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PinVerificationResult &&
        other.isValid == isValid &&
        other.remainingTries == remainingTries;
  }

  @override
  int get hashCode => isValid.hashCode ^ remainingTries.hashCode;
}
