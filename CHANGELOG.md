# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-XX

### Added
- Initial release of Arculus SDK Flutter plugin
- Session initialization functionality
- Wallet creation and recovery
- Public key derivation
- Hash signing capabilities
- PIN verification
- Firmware version retrieval
- GGUID retrieval
- Wallet reset functionality
- Support for multiple cryptographic curves (secp256k1, ed25519, nist256p1)
- Support for multiple signing algorithms (ECDSA, EDDSA, EC Schnorr, etc.)
- Comprehensive error handling with Arculus-specific error codes
- iOS platform support (iOS 12.0+)
- Android platform support (API 24+)
- Integration with Arculus CSDK 1.0.0
- Complete Dart API with typed results
- Documentation and examples

### Technical Details
- Based on Arculus CSDK 1.0.0
- Flutter 3.0.0+ compatibility
- Dart 3.0.0+ compatibility
- Method channel communication between Dart and native platforms
- Proper memory management for native resources
- Thread-safe operations

### Platform Support
- iOS: Static library integration with proper podspec configuration
- Android: JNI integration with native library loading

### API Surface
- `ArculusSdk` main class with all wallet operations
- `ArculusResult<T>` for type-safe result handling
- `ArculusError` for comprehensive error reporting
- Data models for all operation results
- Enums for cryptographic parameters 