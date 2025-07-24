/// Dart equivalents of CSDK types for type-safe usage
library csdk_types;

import 'dart:ffi';
import 'dart:typed_data';

/// Success return code
const int csdkOk = 0;

/// Error codes from CSDK
abstract class CsdkError {
  static const int nullPointer = -100;
  static const int nullAppletObj = -101;
  static const int nullCalloc = -102;
  static const int wrongResponseLength = -103;
  static const int wrongResponseData = -104;
  static const int wrongStatusWord = -105;
  static const int wrongDataLength = -106;
  static const int wrongParamLength = -107;
  static const int wrongPin = -108;
  static const int invalidParam = -109;
  static const int encryptionNotInit = -110;
}

/// Maximum lengths defined in CSDK
abstract class CsdkLimits {
  static const int walletAidLen = 10;
  static const int keyMaxLen = 33;
  static const int walletPinMaxLen = 12;
  static const int walletPinMinLen = 4;
}

/// Curve types for cryptographic operations
enum CurveType {
  secp256k1(1),
  ed25519(2),
  nist256p1(3);

  const CurveType(this.value);
  final int value;
}

/// Algorithm types for signing
enum AlgorithmType {
  undefined(0),
  ecdsa(1),
  eddsa(2),
  ecSchnorr(3),
  ristretto(4),
  cardano(5);

  const AlgorithmType(this.value);
  final int value;
}

/// Dart representation of ExtendedKey structure
class ExtendedKey {
  final Uint8List publicKey;
  final Uint8List chainCodeKey;

  ExtendedKey({
    required this.publicKey,
    required this.chainCodeKey,
  });

  @override
  String toString() {
    return 'ExtendedKey(publicKey: ${publicKey.length} bytes, chainCode: ${chainCodeKey.length} bytes)';
  }
}

/// Dart representation of OperationSelectResponse
class OperationSelectResponse {
  final Uint8List applicationAid;

  OperationSelectResponse({required this.applicationAid});

  @override
  String toString() {
    return 'OperationSelectResponse(AID: ${applicationAid.length} bytes)';
  }
}

/// Result wrapper for CSDK operations
class CsdkResult<T> {
  final bool success;
  final int errorCode;
  final String? errorMessage;
  final T? data;

  CsdkResult.success(this.data)
      : success = true,
        errorCode = csdkOk,
        errorMessage = null;

  CsdkResult.error(this.errorCode, this.errorMessage)
      : success = false,
        data = null;

  @override
  String toString() {
    if (success) {
      return 'CsdkResult.success($data)';
    } else {
      return 'CsdkResult.error($errorCode, $errorMessage)';
    }
  }
}

/// Convert error code to human-readable message
String getErrorMessage(int errorCode) {
  switch (errorCode) {
    case CsdkError.nullPointer:
      return 'Null pointer error';
    case CsdkError.nullAppletObj:
      return 'Null applet object';
    case CsdkError.nullCalloc:
      return 'Memory allocation failed';
    case CsdkError.wrongResponseLength:
      return 'Wrong response length';
    case CsdkError.wrongResponseData:
      return 'Wrong response data';
    case CsdkError.wrongStatusWord:
      return 'Wrong status word';
    case CsdkError.wrongDataLength:
      return 'Wrong data length';
    case CsdkError.wrongParamLength:
      return 'Wrong parameter length';
    case CsdkError.wrongPin:
      return 'Wrong PIN';
    case CsdkError.invalidParam:
      return 'Invalid parameter';
    case CsdkError.encryptionNotInit:
      return 'Encryption not initialized';
    default:
      return 'Unknown error ($errorCode)';
  }
}
