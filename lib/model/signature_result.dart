import 'dart:convert';

/// Result of hash signing operation
class SignatureResult {
  final String signature;
  final int signatureLength;
  final String derivationPath;
  final String hash;

  const SignatureResult({
    required this.signature,
    required this.signatureLength,
    required this.derivationPath,
    required this.hash,
  });

  /// Create from map response
  factory SignatureResult.fromMap(Map<String, dynamic> map) {
    return SignatureResult(
      signature: map['signature'] as String,
      signatureLength: map['signatureLength'] as int,
      derivationPath: map['derivationPath'] as String,
      hash: map['hash'] as String,
    );
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'signature': signature,
      'signatureLength': signatureLength,
      'derivationPath': derivationPath,
      'hash': hash,
    };
  }

  /// Get signature as bytes
  List<int> get signatureBytes {
    return base64.decode(signature);
  }

  /// Get hash as bytes
  List<int> get hashBytes {
    return base64.decode(hash);
  }

  @override
  String toString() {
    return 'SignatureResult(signature: $signature, signatureLength: $signatureLength, '
        'derivationPath: $derivationPath, hash: $hash)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SignatureResult &&
        other.signature == signature &&
        other.signatureLength == signatureLength &&
        other.derivationPath == derivationPath &&
        other.hash == hash;
  }

  @override
  int get hashCode {
    return signature.hashCode ^
        signatureLength.hashCode ^
        derivationPath.hashCode ^
        hash.hashCode;
  }
}
