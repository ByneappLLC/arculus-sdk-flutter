part of '../arculus_sdk_flutter.dart';

final walletAID2 = Uint8List.fromList([
  0x41, // 'A'
  0x52, // 'R'
  0x43, // 'C'
  0x55, // 'U'
  0x4C, // 'L'
  0x55, // 'U'
  0x53, // 'S'
  0x01,
  0x01,
  0x57 // 'W'
]);

class ArculusWallet {
  late Pointer<Void> _pointer;

  ArculusWallet() {
    _pointer = WalletImpl.init();
  }

  Future<void> getPublicKeyFromPath(String path, WalletCurve curve) async {
    final sizeRef = SizeTPointer();

    final pathBytes = Uint8List.fromList(path.codeUnits);

    final reqPointer = WalletImpl.getPublicKeyFromPath(
      _pointer,
      pathBytes,
      curve,
      sizeRef,
    );

    final length = sizeRef.getValue();

    final unsignedBytes = reqPointer.cast<Uint8>().asTypedList(length);
  }

  void selectWalletAID() async {
    final len = SizeTPointer();
    final reqPointer = WalletImpl.selectWalletRequest(
      _pointer,
      walletAID2,
      len,
    );

    final unsignedBytes = reqPointer.cast<Uint8>().asTypedList(len.getValue());

    // final poll = await FlutterNfcKit.poll();

    // final response = await FlutterNfcKit.transceive(unsignedBytes);

    // final decoded = WalletImpl.selectWalletResponse(
    //   _pointer,
    //   response.toPointerUint8(),
    //   response.length,
    // );

    // print(
    //     "Request pointer: ${reqPointer.cast<Uint8>().asTypedList(len.getValue())}.");
    // print("Length: ${len.getValue()}");

    // print("Unsigned bytes: $unsignedBytes");
    // print(
    //     "Hex output: ${unsignedBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}");
  }

  void free() {
    WalletImpl.free(_pointer);
  }
}
