import 'dart:typed_data';

import 'package:arculus_sdk_flutter/arculus_ffi.dart';
import 'package:flutter/material.dart';

import 'package:arculus_sdk_flutter/arculus_sdk_flutter.dart';

void main() {
  ArculusSdkFlutter.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ArculusWallet wallet;
  @override
  void initState() {
    wallet = ArculusWallet();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Arculus example app'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // wallet.getPublicKeyFromPath(
            //   "m/0'",
            //   WalletCurve.secp256k1,
            // );

            //wallet.selectWalletAID();
          },
          child: const Icon(Icons.add),
        ),
        body: Center(
          child: Text('Running on:'),
        ),
      ),
    );
  }
}
