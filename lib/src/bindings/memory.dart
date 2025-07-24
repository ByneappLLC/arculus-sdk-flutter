/// Memory management utilities for FFI operations
library memory_utils;

import 'dart:ffi';
import 'dart:typed_data';

/// Helper class for managing C memory from Dart
class MemoryManager {
  /// Convert Dart string to C string bytes (without null terminator for now)
  static Uint8List stringToBytes(String str) {
    return Uint8List.fromList(str.codeUnits);
  }

  /// Convert Dart Uint8List to typed list for pointer operations
  static Uint8List copyToNative(Uint8List data) {
    return Uint8List.fromList(data);
  }

  /// Convert C uint8_t array to Dart Uint8List
  static Uint8List pointerToUint8List(Pointer<Uint8> ptr, int length) {
    if (ptr == nullptr || length <= 0) return Uint8List(0);
    return Uint8List.fromList(ptr.asTypedList(length));
  }

  /// Convert C string to Dart string
  static String pointerToString(Pointer<Uint8> ptr, int length) {
    if (ptr == nullptr || length <= 0) return '';
    final list = ptr.asTypedList(length);
    // Find null terminator if present
    final nullIndex = list.indexOf(0);
    final actualLength = nullIndex >= 0 ? nullIndex : length;
    return String.fromCharCodes(list.take(actualLength));
  }

  /// Helper to read size_t value from pointer
  static int readSize(Pointer<Size> ptr) {
    return ptr.value;
  }
}

/// Extension for easier pointer operations
extension PointerExtensions on Pointer<Uint8> {
  /// Convert to Uint8List with given length
  Uint8List toUint8List(int length) {
    return MemoryManager.pointerToUint8List(this, length);
  }

  /// Convert to String with given length (avoiding conflict with Object.toString)
  String toDartString(int length) {
    return MemoryManager.pointerToString(this, length);
  }
}

/// Simple wrapper for size_t values in FFI calls
class SizeHolder {
  int value = 0;

  SizeHolder([this.value = 0]);
}
