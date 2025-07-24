/// Signing algorithms supported by Arculus cards
enum SigningAlgorithm {
  /// Default/undefined algorithm
  defaultAlgorithm(0),

  /// ECDSA (Elliptic Curve Digital Signature Algorithm)
  ecdsa(1),

  /// EDDSA (Edwards-curve Digital Signature Algorithm)
  eddsa(2),

  /// EC Schnorr signatures
  ecSchnorr(3),

  /// Ristretto signatures
  ristretto(4),

  /// Cardano signatures
  cardano(5);

  const SigningAlgorithm(this.value);

  /// Numeric value used by the native SDK
  final int value;

  /// Create from integer value
  static SigningAlgorithm fromValue(int value) {
    return SigningAlgorithm.values.firstWhere(
      (algorithm) => algorithm.value == value,
      orElse: () => SigningAlgorithm.defaultAlgorithm,
    );
  }

  @override
  String toString() {
    switch (this) {
      case SigningAlgorithm.defaultAlgorithm:
        return 'Default';
      case SigningAlgorithm.ecdsa:
        return 'ECDSA';
      case SigningAlgorithm.eddsa:
        return 'EDDSA';
      case SigningAlgorithm.ecSchnorr:
        return 'EC Schnorr';
      case SigningAlgorithm.ristretto:
        return 'Ristretto';
      case SigningAlgorithm.cardano:
        return 'Cardano';
    }
  }
}
