import 'package:arculus_sdk/model/model.dart';
import 'src/ffi/arculus_sdk_ffi.dart';

/// Main class for interacting with Arculus hardware wallets
/// Uses FFI for direct C library integration
class ArculusSdk {
  static ArculusSdkFFI? _ffiInstance;
  static bool _isInitialized = false;

  /// Initialize the SDK with FFI implementation
  /// Must be called before using any other methods
  static Future<void> initialize() async {
    if (_isInitialized) return;

    await ArculusSdkFFI.initialize();
    _ffiInstance = ArculusSdkFFI();
    _isInitialized = true;
  }

  /// Get the FFI instance, initializing if necessary
  Future<ArculusSdkFFI> _getInstance() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _ffiInstance!;
  }

  /// Get the platform version
  Future<String?> getPlatformVersion() async {
    final instance = await _getInstance();
    return instance.getPlatformVersion();
  }

  /// Initialize a session with the Arculus card
  /// This must be called before any other operations
  Future<ArculusResult<void>> initSession() async {
    try {
      final instance = await _getInstance();
      final result = await instance.initSession();
      if (result['success'] == true) {
        return ArculusResult.success(null);
      } else {
        return ArculusResult.failure(
          ArculusError.fromMap(result),
        );
      }
    } catch (e) {
      return ArculusResult.failure(
        ArculusError(
          code: -1,
          message: e.toString(),
        ),
      );
    }
  }

  /// Create a new wallet on the Arculus card
  /// [numberOfWords] - Number of mnemonic words (12, 15, 18, 21, or 24)
  Future<ArculusResult<CreateWalletResult>> createWallet({
    int numberOfWords = 12,
  }) async {
    try {
      final instance = await _getInstance();
      final result = await instance.createWallet(numberOfWords);
      if (result['success'] == true) {
        return ArculusResult.success(
          CreateWalletResult.fromMap(result),
        );
      } else {
        return ArculusResult.failure(
          ArculusError.fromMap(result),
        );
      }
    } catch (e) {
      return ArculusResult.failure(
        ArculusError(
          code: -1,
          message: e.toString(),
        ),
      );
    }
  }

  /// Recover a wallet using mnemonic phrase
  /// [mnemonic] - The mnemonic phrase to recover from
  /// [passphrase] - Optional passphrase for additional security
  Future<ArculusResult<void>> recoverWallet(
    String mnemonic, {
    String? passphrase,
  }) async {
    try {
      final instance = await _getInstance();
      final result = await instance.recoverWallet(
        mnemonic,
        passphrase: passphrase,
      );
      if (result['success'] == true) {
        return ArculusResult.success(null);
      } else {
        return ArculusResult.failure(
          ArculusError.fromMap(result),
        );
      }
    } catch (e) {
      return ArculusResult.failure(
        ArculusError(
          code: -1,
          message: e.toString(),
        ),
      );
    }
  }

  /// Get a public key for the specified derivation path
  /// [derivationPath] - BIP32 derivation path (e.g., "m/44'/60'/0'/0/0")
  /// [curve] - Cryptographic curve (1=secp256k1, 2=ed25519, 3=nist256p1)
  Future<ArculusResult<ExtendedPublicKey>> getPublicKey(
    String derivationPath, {
    CryptoCurve curve = CryptoCurve.secp256k1,
  }) async {
    try {
      final instance = await _getInstance();
      final result = await instance.getPublicKey(
        derivationPath,
        curve: curve.value,
      );
      if (result['success'] == true) {
        return ArculusResult.success(
          ExtendedPublicKey.fromMap(result),
        );
      } else {
        return ArculusResult.failure(
          ArculusError.fromMap(result),
        );
      }
    } catch (e) {
      return ArculusResult.failure(
        ArculusError(
          code: -1,
          message: e.toString(),
        ),
      );
    }
  }

  /// Sign a hash using the private key at the specified derivation path
  /// [derivationPath] - BIP32 derivation path
  /// [hash] - Hash to sign (hex string)
  /// [curve] - Cryptographic curve
  /// [algorithm] - Signing algorithm (1=ECDSA, 2=EDDSA, etc.)
  Future<ArculusResult<SignatureResult>> signHash(
    String derivationPath,
    String hash, {
    CryptoCurve curve = CryptoCurve.secp256k1,
    SigningAlgorithm algorithm = SigningAlgorithm.ecdsa,
  }) async {
    try {
      final instance = await _getInstance();
      final result = await instance.signHash(
        derivationPath,
        hash,
        curve: curve.value,
        algorithm: algorithm.value,
      );
      if (result['success'] == true) {
        return ArculusResult.success(
          SignatureResult.fromMap(result),
        );
      } else {
        return ArculusResult.failure(
          ArculusError.fromMap(result),
        );
      }
    } catch (e) {
      return ArculusResult.failure(
        ArculusError(
          code: -1,
          message: e.toString(),
        ),
      );
    }
  }

  /// Verify the PIN for the wallet
  /// [pin] - PIN to verify
  Future<ArculusResult<PinVerificationResult>> verifyPin(String pin) async {
    try {
      final instance = await _getInstance();
      final result = await instance.verifyPin(pin);
      if (result['success'] == true) {
        return ArculusResult.success(
          PinVerificationResult.fromMap(result),
        );
      } else {
        return ArculusResult.failure(
          ArculusError.fromMap(result),
        );
      }
    } catch (e) {
      return ArculusResult.failure(
        ArculusError(
          code: -1,
          message: e.toString(),
        ),
      );
    }
  }

  /// Get the firmware version of the Arculus card
  Future<ArculusResult<String>> getFirmwareVersion() async {
    try {
      final instance = await _getInstance();
      final result = await instance.getFirmwareVersion();
      if (result['success'] == true) {
        return ArculusResult.success(result['version'] as String);
      } else {
        return ArculusResult.failure(
          ArculusError.fromMap(result),
        );
      }
    } catch (e) {
      return ArculusResult.failure(
        ArculusError(
          code: -1,
          message: e.toString(),
        ),
      );
    }
  }

  /// Get the Global Globally Unique Identifier (GGUID) of the wallet
  Future<ArculusResult<String>> getGGUID() async {
    try {
      final instance = await _getInstance();
      final result = await instance.getGGUID();
      if (result['success'] == true) {
        return ArculusResult.success(result['gguid'] as String);
      } else {
        return ArculusResult.failure(
          ArculusError.fromMap(result),
        );
      }
    } catch (e) {
      return ArculusResult.failure(
        ArculusError(
          code: -1,
          message: e.toString(),
        ),
      );
    }
  }

  /// Reset the wallet (WARNING: This will erase all data on the card)
  Future<ArculusResult<void>> resetWallet() async {
    try {
      final instance = await _getInstance();
      final result = await instance.resetWallet();
      if (result['success'] == true) {
        return ArculusResult.success(null);
      } else {
        return ArculusResult.failure(
          ArculusError.fromMap(result),
        );
      }
    } catch (e) {
      return ArculusResult.failure(
        ArculusError(
          code: -1,
          message: e.toString(),
        ),
      );
    }
  }

  /// Clean up resources when done with the SDK
  static void dispose() {
    _ffiInstance?.dispose();
    _ffiInstance = null;
    _isInitialized = false;
  }
}
