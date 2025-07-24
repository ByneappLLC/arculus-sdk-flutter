import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
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
      final status = await FlutterNfcKit.nfcAvailability;
      return status == NFCAvailability.available;
    } catch (e) {
      return false;
    }
  }

  /// Execute wallet operation with proper CSDK flow
  /// This implements the real pattern: Request -> NFC Communication -> Response processing
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

      // Start NFC polling session
      await _startPolling();

      try {
        // Select wallet AID and initialize encrypted session
        await _selectWalletAID(walletAID2);
        await _initEncryptedSession();

        // Execute the actual wallet operation
        final result = await operation(_walletContext!);

        return _successResult({'data': result});
      } finally {
        // Always end NFC session
        await _endPolling();
      }
    } catch (e) {
      return _errorResult(-1, 'Wallet operation failed: $e');
    }
  }

  /// Start NFC polling session
  Future<NFCTag> _startPolling() async {
    final status = await FlutterNfcKit.nfcAvailability;
    if (status == NFCAvailability.available) {
      final tag = await FlutterNfcKit.poll(
        timeout: const Duration(seconds: 60),
        iosMultipleTagMessage: "Multiple tags found",
        iosAlertMessage: "Hold your phone near the card",
        // Make sure we're enabling ISO 7816 / ISO 14443-4 (smart card) support
        readIso14443A: true,
        readIso14443B: true,
        readIso15693: true,
        readIso18092: true,
      );
      print("NFC tag found: ${tag.type}, ID: ${tag.id}");
      print("NFC tag standard: ${tag.standard}");
      print("NFC tag ATQA: ${tag.atqa}, SAK: ${tag.sak}");

      return tag;
    }
    throw Exception('NFC not available');
  }

  /// End NFC polling session
  Future<void> _endPolling() async {
    await FlutterNfcKit.finish();
  }

  /// Send command via NFC and receive response
  Future<Uint8List> _sendCommand(Uint8List command) async {
    final apduStr = _uint8ListToHexString(command);
    print("Sending command -->: $apduStr");
    final res = await FlutterNfcKit.transceive(
      _uint8ListToHexString(command),
      timeout: const Duration(seconds: 5),
    );

    final response = _hexStringToUint8List(res);

    final responseStr = _uint8ListToHexString(response);
    print("Response <--: $responseStr");

    if (response.length < 2 ||
        response[response.length - 2] != 0x90 ||
        response[response.length - 1] != 0x00) {
      throw Exception("sendReceive bad status");
    }

    return response;
  }

  /// Convert Uint8List to hex string
  String _uint8ListToHexString(Uint8List data) {
    return data
        .map((byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join('');
  }

  /// Convert hex string to Uint8List
  Uint8List _hexStringToUint8List(String hex) {
    List<int> bytes = [];
    for (int i = 0; i < hex.length; i += 2) {
      if (i + 2 <= hex.length) {
        bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
      }
    }
    return Uint8List.fromList(bytes);
  }

  /// Select wallet AID (real implementation sends via NFC)
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

      // Send request via NFC
      final adpuCommand = req.cast<Uint8>().asTypedList(rLen.value);
      final result = await _sendCommand(adpuCommand);

      final responseFunc = _walletSelectWalletResponse.asFunction<
          Pointer<Void> Function(Pointer<Void>, Pointer<Uint8>, int)>();

      final resultPtr = malloc<Uint8>(result.length);
      resultPtr.asTypedList(result.length).setAll(0, result);

      final response = responseFunc(_walletContext!, resultPtr, result.length);
      if (response == nullptr) {
        throw Exception('SelectWallet response failed');
      }

      malloc.free(aidPtr);
      malloc.free(resultPtr);
    } finally {
      malloc.free(rLen);
    }
  }

  /// Initialize encrypted session (sends real NFC commands)
  Future<void> _initEncryptedSession() async {
    final rLen = malloc<Size>();

    try {
      final sessionFunc = _walletInitSessionRequest
          .asFunction<Pointer<Uint8> Function(Pointer<Void>, Pointer<Size>)>();

      final req = sessionFunc(_walletContext!, rLen);
      if (req == nullptr) {
        throw Exception('InitEncryptedSession request failed');
      }

      // Send request via NFC
      final adpuCommand = req.cast<Uint8>().asTypedList(rLen.value);
      print("Encrypting session: ${_uint8ListToHexString(adpuCommand)}");
      final result = await _sendCommand(adpuCommand);

      final responseFunc = _walletInitSessionResponse
          .asFunction<int Function(Pointer<Void>, Pointer<Uint8>, int)>();

      final resultPtr = malloc<Uint8>(result.length);
      resultPtr.asTypedList(result.length).setAll(0, result);

      final rc = responseFunc(_walletContext!, resultPtr, result.length);
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

        // Send request via NFC and process response
        final adpuCommand = req.cast<Uint8>().asTypedList(rLen.value);
        final result = await _sendCommand(adpuCommand);

        final extendedKeyFunc = _walletGetPublicKeyFromPathResponse.asFunction<
            Pointer<Void> Function(Pointer<Void>, Pointer<Uint8>, int)>();

        final resultPtr = malloc<Uint8>(result.length);
        resultPtr.asTypedList(result.length).setAll(0, result);

        final extendedKey = extendedKeyFunc(wallet, resultPtr, result.length);
        if (extendedKey == nullptr) {
          throw Exception('Failed to get extended key');
        }

        // Extract public key
        final pubKeyLen = malloc<Size>();
        final pubKey = _extendedKeyGetPubKey.asFunction<
            Pointer<Uint8> Function(
                Pointer<Void>, Pointer<Size>)>()(extendedKey, pubKeyLen);

        if (pubKey == nullptr) {
          throw Exception('Failed to get public key');
        }

        // Extract chain code
        final chainCodeLen = malloc<Size>();
        final chainCode = _extendedKeyGetChainCode.asFunction<
            Pointer<Uint8> Function(
                Pointer<Void>, Pointer<Size>)>()(extendedKey, chainCodeLen);

        if (chainCode == nullptr) {
          throw Exception('Failed to get chain code');
        }

        final pubKeyBytes =
            pubKey.cast<Uint8>().asTypedList(pubKeyLen.value).toList();
        final chainCodeBytes =
            chainCode.cast<Uint8>().asTypedList(chainCodeLen.value).toList();

        malloc.free(pathPtr);
        malloc.free(resultPtr);
        malloc.free(pubKeyLen);
        malloc.free(chainCodeLen);

        return {
          'publicKey': pubKeyBytes,
          'chainCode': chainCodeBytes,
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
