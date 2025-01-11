part of '../../arculus_ffi.dart';

enum WalletCurve {
  defaultCurve(0),
  secp256k1(1),
  ed25519(2),
  nist256p1(3);

  static WalletCurve fromValue(int value) {
    return WalletCurve.values[value];
  }

  const WalletCurve(this.value);

  final int value;
}
