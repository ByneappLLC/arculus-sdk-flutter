import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:nfc_manager/nfc_manager.dart';
import 'package:ffi/ffi.dart';

import '../bindings/types.dart';
import '../../arculus_sdk_platform_interface.dart';

/// Wallet AIDs as defined in the Android example
final walletAID1 = Uint8List.fromList(
    [0x4a, 0x4e, 0x45, 0x54, 0x5f, 0x4c, 0x5f, 0x01, 0x01, 0x57]);
final walletAID2 = Uint8List.fromList(
    [0x41, 0x52, 0x43, 0x55, 0x4c, 0x55, 0x53, 0x01, 0x01, 0x57]);

/// FFI-based implementation of ArculusSdkPlatform with NFC integration
class ArculusSdkFFI extends ArculusSdkPlatform {
  static DynamicLibrary? _library;
  static bool _isInitialized = false;

  // Function pointer types for CSDK functions - as defined in csdk.h
  late final Pointer<NativeFunction<Pointer<Void> Function()>> _walletInit;
  late final Pointer<NativeFunction<Int32 Function(Pointer<Void>)>> _walletFree;
  late final Pointer<
          NativeFunction<Pointer<Uint8> Function(Pointer<Void>, Pointer<Size>)>>
      _walletInitSessionRequest;
  late final Pointer<
          NativeFunction<Int32 Function(Pointer<Void>, Pointer<Uint8>, Size)>>
      _walletInitSessionResponse;
  late final Pointer<
          NativeFunction<
              Pointer<Uint8> Function(
                  Pointer<Void>, Pointer<Uint8>, Size, Pointer<Size>)>>
      _walletSelectWalletRequest;
  late final Pointer<
          NativeFunction<
              Pointer<Void> Function(Pointer<Void>, Pointer<Uint8>, Size)>>
      _walletSelectWalletResponse;
  late final Pointer<
          NativeFunction<Pointer<Uint8> Function(Pointer<Void>, Pointer<Size>)>>
      _walletGetFirmwareVersionRequest;
  late final Pointer<
          NativeFunction<
              Pointer<Uint8> Function(
                  Pointer<Void>, Pointer<Uint8>, Size, Pointer<Size>)>>
      _walletGetFirmwareVersionResponse;
  late final Pointer<
          NativeFunction<Pointer<Uint8> Function(Pointer<Void>, Pointer<Size>)>>
      _walletGetGGUIDRequest;
  late final Pointer<
          NativeFunction<
              Pointer<Uint8> Function(
                  Pointer<Void>, Pointer<Uint8>, Size, Pointer<Size>)>>
      _walletGetGGUIDResponse;
  late final Pointer<
          NativeFunction<
              Pointer<Uint8> Function(
                  Pointer<Void>, Pointer<Uint8>, Size, Pointer<Size>)>>
      _walletVerifyPINRequest;
  late final Pointer<
          NativeFunction<
              Int32 Function(
                  Pointer<Void>, Pointer<Uint8>, Size, Pointer<Size>)>>
      _walletVerifyPINResponse;
  late final Pointer<
          NativeFunction<
              Pointer<Uint8> Function(
                  Pointer<Void>, Pointer<Uint8>, Size, Int16, Pointer<Size>)>>
      _walletGetPublicKeyFromPathRequest;
  late final Pointer<
          NativeFunction<
              Pointer<Void> Function(Pointer<Void>, Pointer<Uint8>, Size)>>
      _walletGetPublicKeyFromPathResponse;
  late final Pointer<
      NativeFunction<
          Pointer<Uint8> Function(
              Pointer<Void>,
              Pointer<Uint8>,
              Size,
              Int16,
              Int8,
              Pointer<Uint8>,
              Size,
              Pointer<Size>)>> _walletSignHashRequest;
  late final Pointer<
          NativeFunction<
              Pointer<Uint8> Function(
                  Pointer<Void>, Pointer<Uint8>, Size, Pointer<Size>)>>
      _walletSignHashResponse;
  late final Pointer<
          NativeFunction<Pointer<Uint8> Function(Pointer<Void>, Pointer<Size>)>>
      _walletResetWalletRequest;
  late final Pointer<
          NativeFunction<Int32 Function(Pointer<Void>, Pointer<Uint8>, Size)>>
      _walletResetWalletResponse;

  // Helper functions for ExtendedKey
  late final Pointer<
          NativeFunction<Pointer<Uint8> Function(Pointer<Void>, Pointer<Size>)>>
      _extendedKeyGetPubKey;
  late final Pointer<
          NativeFunction<Pointer<Uint8> Function(Pointer<Void>, Pointer<Size>)>>
      _extendedKeyGetChainCode;

  // Current wallet context
  Pointer<Void>? _walletContext;
  bool _sessionInitialized = false;

  /// Initialize the FFI library
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _library = _loadLibrary();
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize Arculus SDK: $e');
    }
  }

  /// Load the appropriate native library for the current platform
  static DynamicLibrary _loadLibrary() {
    if (Platform.isAndroid) {
      return DynamicLibrary.open('libcsdk.so');
    } else if (Platform.isIOS || Platform.isMacOS) {
      return DynamicLibrary.process();
    } else if (Platform.isWindows) {
      return DynamicLibrary.open('csdk.dll');
    } else if (Platform.isLinux) {
      return DynamicLibrary.open('libcsdk.so');
    } else {
      throw UnsupportedError('Platform not supported');
    }
  }

  /// Constructor that sets up function pointers
  ArculusSdkFFI() {
    if (!_isInitialized) {
      throw StateError('ArculusSdkFFI must be initialized first');
    }
    _setupFunctionPointers();
  }

  void _setupFunctionPointers() {
    _walletInit = _library!
        .lookup<NativeFunction<Pointer<Void> Function()>>('WalletInit');
    _walletFree = _library!
        .lookup<NativeFunction<Int32 Function(Pointer<Void>)>>('WalletFree');
    _walletInitSessionRequest = _library!.lookup<
        NativeFunction<
            Pointer<Uint8> Function(
                Pointer<Void>, Pointer<Size>)>>('WalletInitSessionRequest');
    _walletInitSessionResponse = _library!.lookup<
        NativeFunction<
            Int32 Function(Pointer<Void>, Pointer<Uint8>,
                Size)>>('WalletInitSessionResponse');
    _walletSelectWalletRequest = _library!.lookup<
        NativeFunction<
            Pointer<Uint8> Function(Pointer<Void>, Pointer<Uint8>, Size,
                Pointer<Size>)>>('WalletSelectWalletRequest');
    _walletSelectWalletResponse = _library!.lookup<
        NativeFunction<
            Pointer<Void> Function(Pointer<Void>, Pointer<Uint8>,
                Size)>>('WalletSelectWalletResponse');
    _walletGetFirmwareVersionRequest = _library!.lookup<
        NativeFunction<
            Pointer<Uint8> Function(Pointer<Void>,
                Pointer<Size>)>>('WalletGetFirmwareVersionRequest');
    _walletGetFirmwareVersionResponse = _library!.lookup<
        NativeFunction<
            Pointer<Uint8> Function(Pointer<Void>, Pointer<Uint8>, Size,
                Pointer<Size>)>>('WalletGetFirmwareVersionResponse');
    _walletGetGGUIDRequest = _library!.lookup<
        NativeFunction<
            Pointer<Uint8> Function(
                Pointer<Void>, Pointer<Size>)>>('WalletGetGGUIDRequest');
    _walletGetGGUIDResponse = _library!.lookup<
        NativeFunction<
            Pointer<Uint8> Function(Pointer<Void>, Pointer<Uint8>, Size,
                Pointer<Size>)>>('WalletGetGGUIDResponse');
    _walletVerifyPINRequest = _library!.lookup<
        NativeFunction<
            Pointer<Uint8> Function(Pointer<Void>, Pointer<Uint8>, Size,
                Pointer<Size>)>>('WalletVerifyPINRequest');
    _walletVerifyPINResponse = _library!.lookup<
        NativeFunction<
            Int32 Function(Pointer<Void>, Pointer<Uint8>, Size,
                Pointer<Size>)>>('WalletVerifyPINResponse');
    _walletGetPublicKeyFromPathRequest = _library!.lookup<
        NativeFunction<
            Pointer<Uint8> Function(Pointer<Void>, Pointer<Uint8>, Size, Int16,
                Pointer<Size>)>>('WalletGetPublicKeyFromPathRequest');
    _walletGetPublicKeyFromPathResponse = _library!.lookup<
        NativeFunction<
            Pointer<Void> Function(Pointer<Void>, Pointer<Uint8>,
                Size)>>('WalletGetPublicKeyFromPathResponse');
    _walletSignHashRequest = _library!.lookup<
        NativeFunction<
            Pointer<Uint8> Function(
                Pointer<Void>,
                Pointer<Uint8>,
                Size,
                Int16,
                Int8,
                Pointer<Uint8>,
                Size,
                Pointer<Size>)>>('WalletSignHashRequest');
    _walletSignHashResponse = _library!.lookup<
        NativeFunction<
            Pointer<Uint8> Function(Pointer<Void>, Pointer<Uint8>, Size,
                Pointer<Size>)>>('WalletSignHashResponse');
    _walletResetWalletRequest = _library!.lookup<
        NativeFunction<
            Pointer<Uint8> Function(
                Pointer<Void>, Pointer<Size>)>>('WalletResetWalletRequest');
    _walletResetWalletResponse = _library!.lookup<
        NativeFunction<
            Int32 Function(Pointer<Void>, Pointer<Uint8>,
                Size)>>('WalletResetWalletResponse');

    // Helper functions for ExtendedKey
    _extendedKeyGetPubKey = _library!.lookup<
        NativeFunction<
            Pointer<Uint8> Function(
                Pointer<Void>, Pointer<Size>)>>('ExtendedKey_getPubKey');
    _extendedKeyGetChainCode = _library!.lookup<
        NativeFunction<
            Pointer<Uint8> Function(
                Pointer<Void>, Pointer<Size>)>>('ExtendedKey_getChainCode');
  }

  @override
  Future<String?> getPlatformVersion() async {
    return 'FFI ${Platform.operatingSystem}';
  }

  /// Check NFC availability
  Future<bool> _checkNfcAvailability() async {
    try {
      return await NfcManager.instance.isAvailable();
    } catch (e) {
      return false;
    }
  }

  /// Execute wallet operation with proper CSDK flow
  /// This demonstrates the real pattern: Request -> NFC Communication -> Response processing
  Future<Map<String, dynamic>> _executeWalletOperation<T>(
    Future<T> Function(Pointer<Void> wallet) operation,
  ) async {
    try {
      // Initialize wallet context if not already done
      if (_walletContext == null) {
        final initFunc = _walletInit.asFunction<Pointer<Void> Function()>();
        _walletContext = initFunc();

        if (_walletContext == nullptr) {
          return _errorResult(
              CsdkError.nullAppletObj, 'Failed to initialize wallet context');
        }
      }

      if (!await _checkNfcAvailability()) {
        return _errorResult(-1, 'NFC not available on this device');
      }

      // In a real implementation, you would:
      // 1. Start NFC session: await NfcManager.instance.startSession(pollingOptions: {NfcPollingOption.iso14443}, ...)
      // 2. Get IsoDep tag: final isoDep = IsoDep.from(tag) or platform-specific equivalent
      // 3. Connect to card: await isoDep.connect()
      // 4. Select wallet AID using _selectWalletAID
      // 5. Initialize encrypted session using _initEncryptedSession
      // 6. Execute the actual wallet operation
      // 7. Close NFC session

      // For demonstration, execute operation directly (would need real NFC for production)
      final result = await operation(_walletContext!);

      return _successResult({'data': result});
    } catch (e) {
      return _errorResult(-1, 'Wallet operation failed: $e');
    }
  }

  /// Simulate wallet AID selection (real implementation would send via NFC)
  Future<void> _selectWalletAID(Uint8List aid) async {
    final rLen = malloc<Size>();

    try {
      final selectFunc = _walletSelectWalletRequest.asFunction<
          Pointer<Uint8> Function(
              Pointer<Void>, Pointer<Uint8>, int, Pointer<Size>)>();

      final aidPtr = malloc<Uint8>(aid.length);
      aidPtr.asTypedList(aid.length).setAll(0, aid);

      final req = selectFunc(_walletContext!, aidPtr, aid.length, rLen);
      if (req == nullptr) {
        throw Exception('SelectWallet request failed');
      }

      // In real implementation: send req.asTypedList(rLen.value) via NFC
      // For now, simulate successful response
      final mockResponse =
          Uint8List.fromList([0x90, 0x00]); // Success status word

      final responseFunc = _walletSelectWalletResponse.asFunction<
          Pointer<Void> Function(Pointer<Void>, Pointer<Uint8>, int)>();

      final resultPtr = malloc<Uint8>(mockResponse.length);
      resultPtr.asTypedList(mockResponse.length).setAll(0, mockResponse);

      final response =
          responseFunc(_walletContext!, resultPtr, mockResponse.length);
      if (response == nullptr) {
        throw Exception('SelectWallet response failed');
      }

      malloc.free(aidPtr);
      malloc.free(resultPtr);
    } finally {
      malloc.free(rLen);
    }
  }

  /// Simulate encrypted session initialization (real implementation would use NFC)
  Future<void> _initEncryptedSession() async {
    final rLen = malloc<Size>();

    try {
      final sessionFunc = _walletInitSessionRequest
          .asFunction<Pointer<Uint8> Function(Pointer<Void>, Pointer<Size>)>();

      final req = sessionFunc(_walletContext!, rLen);
      if (req == nullptr) {
        throw Exception('InitEncryptedSession request failed');
      }

      // In real implementation: send req.asTypedList(rLen.value) via NFC
      // For now, simulate successful response
      final mockResponse =
          Uint8List.fromList([0x90, 0x00]); // Success status word

      final responseFunc = _walletInitSessionResponse
          .asFunction<int Function(Pointer<Void>, Pointer<Uint8>, int)>();

      final resultPtr = malloc<Uint8>(mockResponse.length);
      resultPtr.asTypedList(mockResponse.length).setAll(0, mockResponse);

      final rc = responseFunc(_walletContext!, resultPtr, mockResponse.length);
      if (rc != csdkOk) {
        throw Exception('InitEncryptedSession response failed with code: $rc');
      }

      _sessionInitialized = true;
      malloc.free(resultPtr);
    } finally {
      malloc.free(rLen);
    }
  }

  @override
  Future<Map<String, dynamic>> initSession() async {
    return _executeWalletOperation<bool>((wallet) async {
      // Select wallet AID
      await _selectWalletAID(walletAID2);

      // Initialize encrypted session
      await _initEncryptedSession();

      return true;
    }).then((result) {
      if (result['success'] == true) {
        return _successResult(
            {'sessionId': 'session_${DateTime.now().millisecondsSinceEpoch}'});
      }
      return result;
    });
  }

  @override
  Future<Map<String, dynamic>> createWallet(int numberOfWords) async {
    if (!_sessionInitialized) {
      return _errorResult(-1, 'Session not initialized');
    }

    return _executeWalletOperation<String>((wallet) async {
      // In real implementation: call WalletSeedCreateWalletRequest, send via NFC, process response
      final mockMnemonic = _generateMockMnemonic(numberOfWords);
      return mockMnemonic;
    }).then((result) {
      if (result['success'] == true) {
        return _successResult({'mnemonic': result['data']});
      }
      return result;
    });
  }

  @override
  Future<Map<String, dynamic>> recoverWallet(String mnemonic,
      {String? passphrase}) async {
    if (!_sessionInitialized) {
      return _errorResult(-1, 'Session not initialized');
    }

    return _executeWalletOperation<bool>((wallet) async {
      // In real implementation: call WalletInitRecoverWalletRequest and WalletFinishRecoverWalletRequest
      // with proper NFC communication
      return true;
    }).then((result) {
      if (result['success'] == true) {
        return _successResult({'recovered': result['data']});
      }
      return result;
    });
  }

  @override
  Future<Map<String, dynamic>> getPublicKey(String derivationPath,
      {int curve = 1}) async {
    if (!_sessionInitialized) {
      return _errorResult(-1, 'Session not initialized');
    }

    return _executeWalletOperation<Map<String, dynamic>>((wallet) async {
      final pathBytes = Uint8List.fromList(derivationPath.codeUnits);
      final rLen = malloc<Size>();

      try {
        final pubKeyFunc = _walletGetPublicKeyFromPathRequest.asFunction<
            Pointer<Uint8> Function(
              Pointer<Void>,
              Pointer<Uint8>,
              int,
              int,
              Pointer<Size>,
            )>();

        final pathPtr = malloc<Uint8>(pathBytes.length);
        pathPtr.asTypedList(pathBytes.length).setAll(0, pathBytes);

        final req = pubKeyFunc(wallet, pathPtr, pathBytes.length, curve, rLen);
        if (req == nullptr) {
          throw Exception('GetPublicKey request failed');
        }

        // In real implementation: send req.asTypedList(rLen.value) via NFC and process response
        // For now, return mock data
        final mockPubKey = List.generate(33, (i) => i + 1);
        final mockChainCode = List.generate(32, (i) => i + 10);

        malloc.free(pathPtr);

        return {
          'publicKey': mockPubKey,
          'chainCode': mockChainCode,
          'derivationPath': derivationPath,
          'curve': curve,
        };
      } finally {
        malloc.free(rLen);
      }
    }).then((result) {
      if (result['success'] == true) {
        return _successResult(result['data'] as Map<String, dynamic>);
      }
      return result;
    });
  }

  @override
  Future<Map<String, dynamic>> signHash(String derivationPath, String hash,
      {int curve = 1, int algorithm = 1}) async {
    if (!_sessionInitialized) {
      return _errorResult(-1, 'Session not initialized');
    }

    return _executeWalletOperation<Map<String, dynamic>>((wallet) async {
      final pathBytes = Uint8List.fromList(derivationPath.codeUnits);
      final hashBytes = _hexStringToBytes(hash);
      final rLen = malloc<Size>();

      try {
        final signFunc = _walletSignHashRequest.asFunction<
            Pointer<Uint8> Function(Pointer<Void>, Pointer<Uint8>, int, int,
                int, Pointer<Uint8>, int, Pointer<Size>)>();

        final pathPtr = malloc<Uint8>(pathBytes.length);
        final hashPtr = malloc<Uint8>(hashBytes.length);
        pathPtr.asTypedList(pathBytes.length).setAll(0, pathBytes);
        hashPtr.asTypedList(hashBytes.length).setAll(0, hashBytes);

        final req = signFunc(wallet, pathPtr, pathBytes.length, curve,
            algorithm, hashPtr, hashBytes.length, rLen);
        if (req == nullptr) {
          throw Exception('SignHash request failed');
        }

        // In real implementation: send req.asTypedList(rLen.value) via NFC and process response
        final mockSignature = List.generate(64, (i) => i + 1);

        malloc.free(pathPtr);
        malloc.free(hashPtr);

        return {
          'signature': mockSignature,
          'derivationPath': derivationPath,
          'hash': hash,
          'curve': curve,
          'algorithm': algorithm,
        };
      } finally {
        malloc.free(rLen);
      }
    }).then((result) {
      if (result['success'] == true) {
        return _successResult(result['data'] as Map<String, dynamic>);
      }
      return result;
    });
  }

  @override
  Future<Map<String, dynamic>> verifyPin(String pin) async {
    if (!_sessionInitialized) {
      return _errorResult(-1, 'Session not initialized');
    }

    return _executeWalletOperation<Map<String, dynamic>>((wallet) async {
      final pinBytes = Uint8List.fromList(pin.codeUnits);
      final rLen = malloc<Size>();
      final rTries = malloc<Size>();

      try {
        final verifyFunc = _walletVerifyPINRequest.asFunction<
            Pointer<Uint8> Function(
                Pointer<Void>, Pointer<Uint8>, int, Pointer<Size>)>();

        final pinPtr = malloc<Uint8>(pinBytes.length);
        pinPtr.asTypedList(pinBytes.length).setAll(0, pinBytes);

        final req = verifyFunc(wallet, pinPtr, pinBytes.length, rLen);
        if (req == nullptr) {
          throw Exception('VerifyPIN request failed');
        }

        // In real implementation: send req.asTypedList(rLen.value) via NFC and process response
        malloc.free(pinPtr);

        return {
          'verified': true,
          'attemptsRemaining': 3,
        };
      } finally {
        malloc.free(rLen);
        malloc.free(rTries);
      }
    }).then((result) {
      if (result['success'] == true) {
        return _successResult(result['data'] as Map<String, dynamic>);
      }
      return result;
    });
  }

  @override
  Future<Map<String, dynamic>> getFirmwareVersion() async {
    if (!_sessionInitialized) {
      return _errorResult(-1, 'Session not initialized');
    }

    return _executeWalletOperation<String>((wallet) async {
      final rLen = malloc<Size>();

      try {
        final firmwareFunc = _walletGetFirmwareVersionRequest.asFunction<
            Pointer<Uint8> Function(Pointer<Void>, Pointer<Size>)>();

        final req = firmwareFunc(wallet, rLen);
        if (req == nullptr) {
          throw Exception('GetFirmwareVersion request failed');
        }

        // In real implementation: send req.asTypedList(rLen.value) via NFC and process response
        return '1.0.0';
      } finally {
        malloc.free(rLen);
      }
    }).then((result) {
      if (result['success'] == true) {
        return _successResult({'version': result['data']});
      }
      return result;
    });
  }

  @override
  Future<Map<String, dynamic>> getGGUID() async {
    if (!_sessionInitialized) {
      return _errorResult(-1, 'Session not initialized');
    }

    return _executeWalletOperation<String>((wallet) async {
      final rLen = malloc<Size>();

      try {
        final gguidFunc = _walletGetGGUIDRequest.asFunction<
            Pointer<Uint8> Function(Pointer<Void>, Pointer<Size>)>();

        final req = gguidFunc(wallet, rLen);
        if (req == nullptr) {
          throw Exception('GetGGUID request failed');
        }

        // In real implementation: send req.asTypedList(rLen.value) via NFC and process response
        return 'gguid-${DateTime.now().millisecondsSinceEpoch}';
      } finally {
        malloc.free(rLen);
      }
    }).then((result) {
      if (result['success'] == true) {
        return _successResult({'gguid': result['data']});
      }
      return result;
    });
  }

  @override
  Future<Map<String, dynamic>> resetWallet() async {
    if (!_sessionInitialized) {
      return _errorResult(-1, 'Session not initialized');
    }

    return _executeWalletOperation<bool>((wallet) async {
      final rLen = malloc<Size>();

      try {
        final resetFunc = _walletResetWalletRequest.asFunction<
            Pointer<Uint8> Function(Pointer<Void>, Pointer<Size>)>();

        final req = resetFunc(wallet, rLen);
        if (req == nullptr) {
          throw Exception('ResetWallet request failed');
        }

        // In real implementation: send req.asTypedList(rLen.value) via NFC and process response
        return true;
      } finally {
        malloc.free(rLen);
      }
    }).then((result) {
      if (result['success'] == true) {
        _sessionInitialized = false;
        return _successResult({'reset': result['data']});
      }
      return result;
    });
  }

  /// Clean up resources
  void dispose() {
    if (_walletContext != null && _walletContext != nullptr) {
      final freeFunc = _walletFree.asFunction<int Function(Pointer<Void>)>();
      freeFunc(_walletContext!);
      _walletContext = null;
    }
    _sessionInitialized = false;
  }

  // Helper methods
  Map<String, dynamic> _successResult(Map<String, dynamic> data) {
    return {'success': true, 'errorCode': 0, ...data};
  }

  Map<String, dynamic> _errorResult(int errorCode, String message) {
    return {'success': false, 'errorCode': errorCode, 'errorMessage': message};
  }

  String _generateMockMnemonic(int numberOfWords) {
    final words = [
      'abandon',
      'ability',
      'able',
      'about',
      'above',
      'absent',
      'absorb',
      'abstract',
      'absurd',
      'abuse',
      'access',
      'accident',
      'account',
      'accuse',
      'achieve',
      'acid',
      'acoustic',
      'acquire',
      'across',
      'act',
      'action',
      'actor',
      'actress',
      'actual',
      'adapt',
      'add',
      'addict',
      'address',
      'adjust',
      'admit'
    ];
    return List.generate(numberOfWords, (i) => words[i % words.length])
        .join(' ');
  }

  Uint8List _hexStringToBytes(String hex) {
    // Remove 0x prefix if present
    if (hex.startsWith('0x')) {
      hex = hex.substring(2);
    }
    // Ensure even length
    if (hex.length % 2 != 0) {
      hex = '0$hex';
    }
    return Uint8List.fromList([
      for (int i = 0; i < hex.length; i += 2)
        int.parse(hex.substring(i, i + 2), radix: 16)
    ]);
  }
}
