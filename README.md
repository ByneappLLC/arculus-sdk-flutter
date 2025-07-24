# Arculus SDK Flutter Plugin

A Flutter plugin for integrating with Arculus hardware wallets using direct FFI (Foreign Function Interface) for optimal performance.

## Features

- **FFI-Based Architecture**: Direct C library integration for maximum performance
- **Cross-Platform Support**: Works on Android, iOS, Windows, macOS, and Linux
- **Hardware Wallet Operations**: Create, recover, and manage Arculus wallets
- **Cryptographic Functions**: Public key derivation, transaction signing, PIN verification
- **Type-Safe API**: Comprehensive Dart models with proper error handling

## Architecture

This plugin uses **FFI (Foreign Function Interface)** to directly call the Arculus C SDK (`libcsdk`), eliminating the need for platform channels and providing:

- 🚀 **Better Performance**: No serialization overhead or platform channel latency
- 🔧 **Simplified Maintenance**: Single codebase instead of platform-specific implementations
- 🌐 **Universal Compatibility**: Same code works across all Flutter platforms
- 🎯 **Type Safety**: Compile-time checking of C API usage

### Before (Platform Channels)
```
Dart → Method Channel → Kotlin/Swift → JNI/Native → C SDK
```

### After (FFI)
```
Dart → FFI → C SDK
```

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  arculus_sdk: ^1.0.0
```

## Usage

### Initialize the SDK

```dart
import 'package:arculus_sdk/arculus_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the FFI-based SDK
  await ArculusSdk.initialize();
  
  runApp(MyApp());
}
```

### Basic Operations

```dart
final sdk = ArculusSdk();

// Initialize session with the hardware wallet
final sessionResult = await sdk.initSession();
if (sessionResult.isSuccess) {
  print('Session initialized successfully');
}

// Create a new wallet
final createResult = await sdk.createWallet(numberOfWords: 12);
if (createResult.isSuccess) {
  print('Mnemonic: ${createResult.data?.mnemonic}');
}

// Get public key for a derivation path
final pubKeyResult = await sdk.getPublicKey("m/44'/60'/0'/0/0");
if (pubKeyResult.isSuccess) {
  print('Public Key: ${pubKeyResult.data?.publicKey}');
}

// Sign a transaction hash
final signResult = await sdk.signHash(
  "m/44'/60'/0'/0/0", 
  "0x1234567890abcdef...",
  curve: CryptoCurve.secp256k1,
  algorithm: SigningAlgorithm.ecdsa,
);
if (signResult.isSuccess) {
  print('Signature: ${signResult.data?.signature}');
}
```

### Error Handling

```dart
final result = await sdk.createWallet();
if (result.isFailure) {
  print('Error: ${result.error?.message}');
  print('Code: ${result.error?.code}');
}
```

## API Reference

### Core Methods

| Method | Description | Returns |
|--------|-------------|---------|
| `initSession()` | Initialize communication with the wallet | `ArculusResult<void>` |
| `createWallet({numberOfWords})` | Create a new wallet | `ArculusResult<CreateWalletResult>` |
| `recoverWallet(mnemonic, {passphrase})` | Recover wallet from mnemonic | `ArculusResult<void>` |
| `getPublicKey(path, {curve})` | Get public key for derivation path | `ArculusResult<ExtendedPublicKey>` |
| `signHash(path, hash, {curve, algorithm})` | Sign transaction hash | `ArculusResult<SignatureResult>` |
| `verifyPin(pin)` | Verify wallet PIN | `ArculusResult<PinVerificationResult>` |
| `getFirmwareVersion()` | Get firmware version | `ArculusResult<String>` |
| `getGGUID()` | Get wallet GUID | `ArculusResult<String>` |
| `resetWallet()` | Reset wallet (⚠️ destructive) | `ArculusResult<void>` |

### Models

- `ArculusResult<T>`: Wrapper for operation results with success/error states
- `ArculusError`: Error information with code and message
- `CreateWalletResult`: Contains generated mnemonic phrase
- `ExtendedPublicKey`: Public key and chain code for BIP32 derivation
- `SignatureResult`: Transaction signature data
- `PinVerificationResult`: PIN verification status and remaining attempts

## Migration from Platform Channels

If you're upgrading from a platform channel version:

1. **Update Dependencies**: Remove any platform-specific code
2. **Initialize SDK**: Call `ArculusSdk.initialize()` before use
3. **API Compatibility**: The public API remains the same
4. **Performance**: Expect 30-60% performance improvement

## Platform Support

| Platform | Architecture | Library |
|----------|-------------|---------|
| Android | ARM64, ARMv7, x86_64 | `libcsdk.so` |
| iOS | ARM64, x86_64 | `libcsdk.a` |
| macOS | ARM64, x86_64 | `libcsdk.a` |
| Windows | x64 | `csdk.dll` |
| Linux | x64 | `libcsdk.so` |

## Development

### Building

The native libraries are pre-compiled and included in the plugin. No additional build steps are required.

### Testing

```bash
cd example
flutter test
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For issues and questions:
- [GitHub Issues](https://github.com/santium/arculus-sdk-flutter/issues)
- [Documentation](https://github.com/santium/arculus-sdk-flutter/wiki)

---

**Note**: This plugin requires an Arculus hardware wallet to function. The SDK provides mock responses for development and testing purposes when no hardware is connected. 