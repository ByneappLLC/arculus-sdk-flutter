/// Result of wallet creation operation
class CreateWalletResult {
  final String mnemonic;
  final int numberOfWords;

  const CreateWalletResult({
    required this.mnemonic,
    required this.numberOfWords,
  });

  /// Create from map response
  factory CreateWalletResult.fromMap(Map<String, dynamic> map) {
    return CreateWalletResult(
      mnemonic: map['mnemonic'] as String,
      numberOfWords: map['numberOfWords'] as int,
    );
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'mnemonic': mnemonic,
      'numberOfWords': numberOfWords,
    };
  }

  @override
  String toString() {
    return 'CreateWalletResult(mnemonic: $mnemonic, numberOfWords: $numberOfWords)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CreateWalletResult &&
        other.mnemonic == mnemonic &&
        other.numberOfWords == numberOfWords;
  }

  @override
  int get hashCode => mnemonic.hashCode ^ numberOfWords.hashCode;
}
