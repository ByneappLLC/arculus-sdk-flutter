import 'dart:ffi';

import 'package:arculus_sdk_flutter/arculus_ffi.dart';
import 'package:arculus_sdk_flutter/arculus_sdk_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

class TestAPDUCommands {
  static const selectWallet = "00A404000A415243554C5553010157";
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    ArculusSdkFlutter.init();
  });

  test("Create correct APDU command for select wallet", () {
    final pointer = WalletImpl.init();
    final len = SizeTPointer();
    final reqPointer = WalletImpl.selectWalletRequest(
      pointer,
      walletAID2,
      len,
    );

    final unsignedBytes = reqPointer.cast<Uint8>().asTypedList(len.getValue());

    final hex =
        unsignedBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');

    expect(hex.toUpperCase(), TestAPDUCommands.selectWallet);
  });
}
