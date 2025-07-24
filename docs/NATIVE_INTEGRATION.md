# Arculus SDK Flutter - Native Library Integration

This document explains how the Arculus CSDK native libraries have been integrated into the Flutter plugin.

## Overview

The Arculus SDK Flutter plugin now includes the native CSDK libraries for both Android and iOS platforms, enabling FFI (Foreign Function Interface) access to the Arculus card functionality.

## Android Integration

### Libraries Included
- **ARM64-v8a**: `libcsdk.so` for 64-bit ARM devices
- **ARMv7**: `libcsdk.so` for 32-bit ARM devices  
- **x86_64**: `libcsdk.so` for x86_64 emulators/devices

### Integration Details
- Native libraries are located in `android/src/main/jniLibs/`
- JNA (Java Native Access) dependency is included for native library binding
- `CSDKLibrary.kt` class handles library loading
- ProGuard rules protect JNA and CSDK symbols from obfuscation

### Build Configuration
```gradle
dependencies {
    implementation 'net.java.dev.jna:5.12.1@aar'
}

android {
    defaultConfig {
        minSdkVersion 24
        ndk {
            abiFilters 'arm64-v8a', 'armeabi-v7a', 'x86_64'
        }
    }
}
```

## iOS Integration

### Libraries Included
- **XCFramework**: `CSDK.xcframework` containing:
  - iOS device library (ARM64)
  - iOS simulator library (x86_64 + ARM64)

### Integration Details
- XCFramework is located in `ios/CSDK.xcframework/`
- Includes C headers for FFI access
- Podspec configuration handles framework linking
- Supports both device and simulator architectures

### Podspec Configuration
```ruby
s.vendored_frameworks = 'CSDK.xcframework'
s.source_files = 'Classes/**/*'
```

## Usage

The native libraries are automatically loaded when the plugin is initialized. For FFI usage:

1. **Android**: Libraries are loaded via JNA through `CSDKLibrary`
2. **iOS**: XCFramework provides direct C function access

## Header Files

C header files are available for FFI binding:
- `csdk.h` - Main CSDK API functions
- `csdk_types.h` - Type definitions and constants

## Requirements

### Android
- Minimum SDK: API level 24 (Android 7.0)
- JNA library for native access
- Supported architectures: ARM64, ARMv7, x86_64

### iOS  
- Minimum iOS version: 12.0
- XCFramework with universal binary support
- NFC capabilities for card communication

## Notes

- Libraries are embedded directly in the plugin to avoid external dependencies
- ProGuard/R8 rules protect native symbols during code obfuscation
- XCFramework provides optimal iOS integration with architecture selection
- All libraries are statically linked for better distribution 