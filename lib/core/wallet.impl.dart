part of '../arculus_ffi.dart';

class WalletImpl extends WalletFFI {
  static Pointer<Void> init() {
    return WalletFFI.walletInit();
  }

  static int free(Pointer<Void> wallet) {
    return WalletFFI.walletFree(wallet);
  }

  static Pointer<Uint8> getPublicKeyFromPath(
    Pointer<Void> wallet,
    Uint8List path,
    WalletCurve curve,
    SizeTPointer len,
  ) {
    // Ensure curve is treated as uint16_t
    final curveValue = curve.value & 0xFFFF;

    final pathPointer = path.toPointerUint8();

    final result = WalletFFI.walletGetPublicKeyFromPathRequest(
      wallet,
      pathPointer,
      path.length,
      curveValue,
      len.pointer,
    );

    calloc.free(pathPointer);
    return result;
  }

  static Pointer<Uint8> selectWalletRequest(
    Pointer<Void> wallet,
    Uint8List aid,
    SizeTPointer len,
  ) {
    return WalletFFI.walletSelectWalletRequest(
      wallet,
      aid.toPointerUint8(),
      len.pointer,
    );
  }

  static Pointer<OperationSelectResponse> selectWalletResponse(
    Pointer<Void> wallet,
    Pointer<Uint8> response,
    int responseLength,
  ) {
    return WalletFFI.walletSelectWalletResponse(
      wallet,
      response,
      responseLength,
    );
  }
}
