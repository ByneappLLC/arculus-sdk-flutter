/// FFI-based Arculus SDK implementation
library arculus_sdk_ffi;

export 'src/ffi/arculus_sdk_ffi.dart';
export 'src/bindings/types.dart';

import 'src/ffi/arculus_sdk_ffi.dart';
import 'arculus_sdk_platform_interface.dart';

/// Initialize the FFI-based Arculus SDK
/// Call this before using any SDK functions
Future<void> initializeArculusSDKFFI() async {
  await ArculusSdkFFI.initialize();
  ArculusSdkPlatform.instance = ArculusSdkFFI();
}

/// Check if the FFI implementation is available on the current platform
bool isFFISupported() {
  try {
    return ArculusSdkFFI.initialize != null;
  } catch (e) {
    return false;
  }
}
