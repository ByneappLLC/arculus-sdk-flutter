/// Base platform interface for Arculus SDK implementations
abstract class ArculusSdkPlatform {
  /// Constructs a ArculusSdkPlatform.
  ArculusSdkPlatform();

  static ArculusSdkPlatform? _instance;

  /// The current instance of [ArculusSdkPlatform].
  static ArculusSdkPlatform? get instance => _instance;

  /// Set the platform implementation instance
  static set instance(ArculusSdkPlatform? instance) {
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('getPlatformVersion() has not been implemented.');
  }

  Future<Map<String, dynamic>> initSession() {
    throw UnimplementedError('initSession() has not been implemented.');
  }

  Future<Map<String, dynamic>> createWallet(int numberOfWords) {
    throw UnimplementedError('createWallet() has not been implemented.');
  }

  Future<Map<String, dynamic>> recoverWallet(String mnemonic,
      {String? passphrase}) {
    throw UnimplementedError('recoverWallet() has not been implemented.');
  }

  Future<Map<String, dynamic>> getPublicKey(String derivationPath,
      {int curve = 1}) {
    throw UnimplementedError('getPublicKey() has not been implemented.');
  }

  Future<Map<String, dynamic>> signHash(String derivationPath, String hash,
      {int curve = 1, int algorithm = 1}) {
    throw UnimplementedError('signHash() has not been implemented.');
  }

  Future<Map<String, dynamic>> verifyPin(String pin) {
    throw UnimplementedError('verifyPin() has not been implemented.');
  }

  Future<Map<String, dynamic>> getFirmwareVersion() {
    throw UnimplementedError('getFirmwareVersion() has not been implemented.');
  }

  Future<Map<String, dynamic>> getGGUID() {
    throw UnimplementedError('getGGUID() has not been implemented.');
  }

  Future<Map<String, dynamic>> resetWallet() {
    throw UnimplementedError('resetWallet() has not been implemented.');
  }
}
