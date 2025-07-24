import 'dart:convert';

/// Extended public key containing both public key and chain code
class ExtendedPublicKey {
  final String publicKey;
  final String chainCode;
  final int publicKeyLength;
  final int chainCodeLength;

  const ExtendedPublicKey({
    required this.publicKey,
    required this.chainCode,
    required this.publicKeyLength,
    required this.chainCodeLength,
  });

  /// Create from map response
  factory ExtendedPublicKey.fromMap(Map<String, dynamic> map) {
    return ExtendedPublicKey(
      publicKey: map['publicKey'] as String,
      chainCode: map['chainCode'] as String,
      publicKeyLength: map['publicKeyLength'] as int,
      chainCodeLength: map['chainCodeLength'] as int,
    );
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'publicKey': publicKey,
      'chainCode': chainCode,
      'publicKeyLength': publicKeyLength,
      'chainCodeLength': chainCodeLength,
    };
  }

  /// Get public key as bytes
  List<int> get publicKeyBytes {
    return base64.decode(publicKey);
  }

  /// Get chain code as bytes
  List<int> get chainCodeBytes {
    return base64.decode(chainCode);
  }

  @override
  String toString() {
    return 'ExtendedPublicKey(publicKey: $publicKey, chainCode: $chainCode, '
        'publicKeyLength: $publicKeyLength, chainCodeLength: $chainCodeLength)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExtendedPublicKey &&
        other.publicKey == publicKey &&
        other.chainCode == chainCode &&
        other.publicKeyLength == publicKeyLength &&
        other.chainCodeLength == chainCodeLength;
  }

  @override
  int get hashCode {
    return publicKey.hashCode ^
        chainCode.hashCode ^
        publicKeyLength.hashCode ^
        chainCodeLength.hashCode;
  }
}
