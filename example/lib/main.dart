import 'package:flutter/material.dart';
import 'package:arculus_sdk/arculus_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ArculusSdk _arculusSdk = ArculusSdk();
  String _statusText = 'Ready';
  bool _sessionInitialized = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arculus SDK Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Arculus SDK Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(_statusText),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initSession,
                child: const Text('Initialize Session'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _sessionInitialized ? _createWallet : null,
                child: const Text('Create Wallet'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _sessionInitialized ? _getPublicKey : null,
                child: const Text('Get Public Key'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _sessionInitialized ? _getFirmwareVersion : null,
                child: const Text('Get Firmware Version'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _sessionInitialized ? _getGGUID : null,
                child: const Text('Get GGUID'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _initSession() async {
    setState(() {
      _statusText = 'Initializing session...';
    });

    try {
      final result = await _arculusSdk.initSession();
      if (result.isSuccess) {
        setState(() {
          _statusText = 'Session initialized successfully';
          _sessionInitialized = true;
        });
      } else {
        setState(() {
          _statusText = 'Failed to initialize session: ${result.error}';
          _sessionInitialized = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusText = 'Error: $e';
        _sessionInitialized = false;
      });
    }
  }

  Future<void> _createWallet() async {
    setState(() {
      _statusText = 'Creating wallet...';
    });

    try {
      final result = await _arculusSdk.createWallet(numberOfWords: 12);
      if (result.isSuccess) {
        final walletResult = result.value;
        setState(() {
          _statusText =
              'Wallet created!\nMnemonic: ${walletResult.mnemonic.substring(0, 50)}...';
        });
      } else {
        setState(() {
          _statusText = 'Failed to create wallet: ${result.error}';
        });
      }
    } catch (e) {
      setState(() {
        _statusText = 'Error: $e';
      });
    }
  }

  Future<void> _getPublicKey() async {
    setState(() {
      _statusText = 'Getting public key...';
    });

    try {
      final result = await _arculusSdk.getPublicKey(
        "m/44'/60'/0'/0/0",
        curve: CryptoCurve.secp256k1,
      );
      if (result.isSuccess) {
        final extendedKey = result.value;
        setState(() {
          _statusText =
              'Public key retrieved!\nKey: ${extendedKey.publicKey.substring(0, 20)}...';
        });
      } else {
        setState(() {
          _statusText = 'Failed to get public key: ${result.error}';
        });
      }
    } catch (e) {
      setState(() {
        _statusText = 'Error: $e';
      });
    }
  }

  Future<void> _getFirmwareVersion() async {
    setState(() {
      _statusText = 'Getting firmware version...';
    });

    try {
      final result = await _arculusSdk.getFirmwareVersion();
      if (result.isSuccess) {
        setState(() {
          _statusText = 'Firmware version: ${result.value}';
        });
      } else {
        setState(() {
          _statusText = 'Failed to get firmware version: ${result.error}';
        });
      }
    } catch (e) {
      setState(() {
        _statusText = 'Error: $e';
      });
    }
  }

  Future<void> _getGGUID() async {
    setState(() {
      _statusText = 'Getting GGUID...';
    });

    try {
      final result = await _arculusSdk.getGGUID();
      if (result.isSuccess) {
        setState(() {
          _statusText = 'GGUID: ${result.value}';
        });
      } else {
        setState(() {
          _statusText = 'Failed to get GGUID: ${result.error}';
        });
      }
    } catch (e) {
      setState(() {
        _statusText = 'Error: $e';
      });
    }
  }
}
