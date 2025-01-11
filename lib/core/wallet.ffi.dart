part of '../arculus_ffi.dart';

abstract class WalletFFI {
  /// @brief Allocates and populates a Wallet struct that must be freed by calling WalletFree()
  /// @return wallet pointer
  static Pointer<Void> walletInit() {
    return _walletInit();
  }

  static final _walletInitPtr =
      _lookup<NativeFunction<_c_walletInit>>('WalletInit');

  static final _walletInit = _walletInitPtr.asFunction<_dart_walletInit>();

  /// @brief Frees memory allocated for wallet
  /// @param wallet AppletObj wallet structure containing list of pointers(ex: apdu commands...etc)
  static int walletFree(
    Pointer<Void> wallet,
  ) {
    return _walletFree(
      wallet,
    );
  }

  static final _walletFreePtr =
      _lookup<NativeFunction<_c_walletFree>>('WalletFree');
  static final _walletFree = _walletFreePtr.asFunction<_dart_walletFree>();

  /// @brief Function used to retrieve Public Key of a certain given path.
  ///
  /// @param wallet AppletObj context object created by WalletInit() used in all subsequent API calls
  /// @param[in] bipPath Path in ascii (and decimal for elts): ex: "m/44h/60h/0h/0/0" or "m/44'/60'/0'/0/0"
  /// @param[in] bipPathLength The length of the BIP path
  /// @param[in] Curve to use 0 default, 1 Secp256k1, 2 ED25519, 3 NIST256P1
  /// @param[out] len the function fill out this value with the length of the command (or response for functions handling responses)
  /// @return The command to be sent to the card
  static Pointer<Uint8> walletGetPublicKeyFromPathRequest(
    Pointer<Void> wallet,
    Pointer<Uint8> bipPath,
    int bipPathLength,
    int curve,
    Pointer<SizeT> len,
  ) {
    return _WalletGetPublicKeyFromPathRequest(
      wallet,
      bipPath,
      bipPathLength,
      curve,
      len,
    );
  }

  static final _WalletGetPublicKeyFromPathRequestPtr =
      _lookup<NativeFunction<_c_walletGetPublicKeyFromPathRequest>>(
          'WalletGetPublicKeyFromPathRequest');

  static final _WalletGetPublicKeyFromPathRequest =
      _WalletGetPublicKeyFromPathRequestPtr.asFunction<
          _dart_walletGetPublicKeyFromPathRequest>();

  /// @brief Select Wallet applet
  ///
  /// @param wallet AppletObj wallet structure containing list of pointers(ex: apdu commands...etc)
  /// @return command pointer to a char*. The function with fill this "char array" with the appropriate APDU command to be sent by the client
  static Pointer<Uint8> walletSelectWalletRequest(
    Pointer<Void> wallet,
    Pointer<Uint8> aid,
    Pointer<SizeT> len,
  ) {
    return _WalletSelectWalletRequest(
      wallet,
      aid,
      len,
    );
  }

  static final _WalletSelectWalletRequestPtr =
      _lookup<NativeFunction<_c_walletSelectWalletRequest>>(
          'WalletSelectWalletRequest');

  static final _WalletSelectWalletRequest = _WalletSelectWalletRequestPtr
      .asFunction<_dart_walletSelectWalletRequest>();

  /// @brief Parse response to Wallet Select response
  ///
  /// @param wallet AppletObj context object created by WalletInit() used in all subsequent API calls
  /// @param[in] response : Response to be parsed, sent by the client
  /// @param[in] responseLength : length in bytes of the response
  /// @return resps pointer to OperationSelectResponse* struct, will be filled by the function after parsing provided response
  static Pointer<OperationSelectResponse> walletSelectWalletResponse(
    Pointer<Void> wallet,
    Pointer<Uint8> response,
    int responseLength,
  ) {
    return _WalletSelectWalletResponse(
      wallet,
      response,
      responseLength,
    );
  }

  static final _WalletSelectWalletResponsePtr =
      _lookup<NativeFunction<_c_walletSelectWalletResponse>>(
          'WalletSelectWalletResponse');

  static final _WalletSelectWalletResponse = _WalletSelectWalletResponsePtr
      .asFunction<_dart_walletSelectWalletResponse>();
}

/// @brief Structure to grouping required data structs for applet selection
final class OperationSelectResponse extends Struct {
  external Pointer<UnsignedChar> ApplicationAID;

  @Int()
  external int ApplicationAIDLength;
}

typedef _c_walletInit = Pointer<Void> Function();

typedef _dart_walletInit = Pointer<Void> Function();

typedef _c_walletFree = Int Function(Pointer<Void> wallet);

typedef _dart_walletFree = int Function(Pointer<Void> wallet);

typedef _c_walletGetPublicKeyFromPathRequest = Pointer<Uint8> Function(
  Pointer<Void> wallet,
  Pointer<Uint8> bipPath,
  Size bipPathLength,
  Uint16 curve,
  Pointer<SizeT> len,
);

typedef _dart_walletGetPublicKeyFromPathRequest = Pointer<Uint8> Function(
  Pointer<Void> wallet,
  Pointer<Uint8> bipPath,
  int bipPathLength,
  int curve,
  Pointer<SizeT> len,
);

typedef _c_walletSelectWalletRequest = Pointer<Uint8> Function(
  Pointer<Void> wallet,
  Pointer<Uint8> aid,
  Pointer<SizeT> len,
);

typedef _dart_walletSelectWalletRequest = Pointer<Uint8> Function(
  Pointer<Void> wallet,
  Pointer<Uint8> aid,
  Pointer<SizeT> len,
);

typedef _c_walletSelectWalletResponse = Pointer<OperationSelectResponse>
    Function(
  Pointer<Void> wallet,
  Pointer<Uint8> response,
  Int responseLength,
);

typedef _dart_walletSelectWalletResponse = Pointer<OperationSelectResponse>
    Function(
  Pointer<Void> wallet,
  Pointer<Uint8> response,
  int responseLength,
);
