library arculus_sdk_flutter;

import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:arculus_sdk_flutter/arculus_ffi.dart';

part 'core/wallet.dart';

class ArculusSdkFlutter {
  static void init() {
    arculusLib = Platform.isAndroid
        ? DynamicLibrary.open("libcsdk.so")
        : DynamicLibrary.process();
  }
}
