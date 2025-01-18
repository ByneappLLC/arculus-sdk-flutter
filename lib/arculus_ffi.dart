library arculus_sdk_ffi;

import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

part 'core/wallet.ffi.dart';
part 'core/wallet.impl.dart';
part 'core/model/extension.dart';
part 'core/model/size_t_pointer.dart';
part 'core/model/wallet_curve.dart';

late DynamicLibrary arculusLib;

final Pointer<T> Function<T extends NativeType>(String symbolName) _lookup =
    arculusLib.lookup;
