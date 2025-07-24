# Migration from Old Arculus SDK

This document guides you through migrating from `arculus-sdk-old` to the updated `arculus-sdk-flutter` with proper `flutter_nfc_kit` integration.

## Key Changes

### 1. Dependency Changes
**Old SDK (`arculus-sdk-old`):**
```yaml
dependencies:
  flutter_nfc_kit: ^3.6.0-rc.6
  ffi: ^2.1.3
```

**New SDK (`arculus-sdk-flutter`):**
```yaml
dependencies:
  arculus_sdk: ^1.0.1
```
The new SDK includes `flutter_nfc_kit` as a transitive dependency.

### 2. NFC Implementation
**Old SDK Pattern:**
- Manual NFC session management
- Direct APDU command handling
- Custom wallet operations

**New SDK Pattern:**
- Integrated NFC session management within FFI operations
- Automatic CSDK flow: Request → NFC → Response
- Complete wallet operations via SDK interface

### 3. Android Configuration

#### Minimum SDK Version
**Updated Requirement:**
```gradle
android {
    defaultConfig {
        minSdk 26  // Updated from 24
    }
}
```

#### NDK Version
```gradle
android {
    ndkVersion = "27.0.12077973"
}
```

#### Permissions
```xml
<uses-permission android:name="android.permission.NFC" />
```

### 4. iOS Configuration

#### Info.plist
```xml
<key>NFCReaderUsageDescription</key>
<string>This app uses NFC to read data from NFC tags.</string>
<key>com.apple.developer.nfc.readersession.iso7816.select-identifiers</key>
<array>
    <string>D2760000850101</string>
</array>
```

#### Entitlements (Runner.entitlements)
```xml
<key>com.apple.developer.nfc.readersession.formats</key>
<array>
    <string>TAG</string>
</array>
```

## Code Migration

### Old SDK Usage
```dart
final wallet = ArculusWallet();
final publicKey = await wallet.getPublicKeyFromPath(
  "m/0'",
  WalletCurve.secp256k1,
);
```

### New SDK Usage
```dart
await ArculusSdk.initialize();
final sdk = ArculusSdk();

// Initialize session
final sessionResult = await sdk.initSession();
if (sessionResult.isSuccess) {
  // Get public key
  final result = await sdk.getPublicKey("m/0'", curve: 1);
  if (result.isSuccess) {
    final publicKey = result.data?.publicKey;
  }
}
```

## Benefits of Migration

1. **Simplified API**: Single SDK with comprehensive error handling
2. **Type Safety**: Strongly typed results with `ArculusResult<T>`
3. **Automatic Session Management**: No manual NFC session handling required
4. **Real Hardware Communication**: Actual CSDK integration via NFC
5. **Better Error Handling**: Comprehensive error codes and messages
6. **Cross-Platform**: Consistent API across Android and iOS

## Breaking Changes

1. **API Surface**: Complete rewrite with new method signatures
2. **Error Handling**: New `ArculusResult<T>` pattern instead of direct returns
3. **Dependencies**: Switched from direct `flutter_nfc_kit` usage to integrated SDK
4. **Android**: Increased minimum SDK version to 26
5. **Session Management**: Automatic instead of manual

## Migration Checklist

- [ ] Update `pubspec.yaml` to use new SDK
- [ ] Update Android `minSdk` to 26
- [ ] Update Android NDK version to 27.0.12077973
- [ ] Add NFC permissions to Android manifest
- [ ] Update iOS Info.plist with NFC configuration
- [ ] Create iOS entitlements file
- [ ] Rewrite application code to use new API
- [ ] Test NFC functionality with hardware wallet
- [ ] Update error handling to use `ArculusResult<T>` pattern

## Support

For issues during migration, please refer to:
- [Native Integration Guide](NATIVE_INTEGRATION.md)
- [SDK Documentation](../README.md)
- Example app in `/example` directory 