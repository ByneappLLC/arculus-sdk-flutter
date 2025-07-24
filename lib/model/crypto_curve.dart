/// Cryptographic curves supported by Arculus cards
enum CryptoCurve {
  /// Default curve
  defaultCurve(0),

  /// secp256k1 curve (Bitcoin, Ethereum)
  secp256k1(1),

  /// Ed25519 curve (Solana, Cardano)
  ed25519(2),

  /// NIST P-256 curve
  nist256p1(3);

  const CryptoCurve(this.value);

  /// Numeric value used by the native SDK
  final int value;

  /// Create from integer value
  static CryptoCurve fromValue(int value) {
    return CryptoCurve.values.firstWhere(
      (curve) => curve.value == value,
      orElse: () => CryptoCurve.defaultCurve,
    );
  }

  @override
  String toString() {
    switch (this) {
      case CryptoCurve.defaultCurve:
        return 'Default';
      case CryptoCurve.secp256k1:
        return 'secp256k1';
      case CryptoCurve.ed25519:
        return 'Ed25519';
      case CryptoCurve.nist256p1:
        return 'NIST P-256';
    }
  }
}
