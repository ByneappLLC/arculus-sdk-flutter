/// Error class representing Arculus SDK errors
class ArculusError {
  final int code;
  final String message;

  const ArculusError({
    required this.code,
    required this.message,
  });

  /// Create an ArculusError from a map response
  factory ArculusError.fromMap(Map<String, dynamic> map) {
    return ArculusError(
      code: map['errorCode'] as int? ?? -1,
      message: map['errorMessage'] as String? ?? 'Unknown error',
    );
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'errorCode': code,
      'errorMessage': message,
    };
  }

  @override
  String toString() {
    return 'ArculusError(code: $code, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ArculusError &&
        other.code == code &&
        other.message == message;
  }

  @override
  int get hashCode => code.hashCode ^ message.hashCode;

  // Common error codes from CSDK
  static const int ok = 0;
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
