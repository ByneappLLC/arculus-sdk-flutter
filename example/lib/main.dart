import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
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
  String _platformVersion = 'Unknown';
  String _statusMessage = 'Ready';
  final _arculusSdk = ArculusSdk();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      await ArculusSdk.initialize();
      _isInitialized = true;
      platformVersion =
          await _arculusSdk.getPlatformVersion() ?? 'Unknown platform version';
      setState(() {
        _statusMessage = 'SDK Initialized';
      });
    } on PlatformException catch (e) {
      platformVersion = 'Failed to get platform version: ${e.message}';
      setState(() {
        _statusMessage = 'Initialization failed: ${e.message}';
      });
    } catch (e) {
      platformVersion = 'Failed to get platform version: $e';
      setState(() {
        _statusMessage = 'Initialization failed: $e';
      });
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> _initSession() async {
    if (!_isInitialized) {
      setState(() {
        _statusMessage = 'SDK not initialized';
      });
      return;
    }

    setState(() {
      _statusMessage = 'Initializing session...';
    });

    try {
      final result = await _arculusSdk.initSession();
      if (result.isSuccess) {
        setState(() {
          _statusMessage = 'Session initialized successfully';
        });
      } else {
        setState(() {
          _statusMessage =
              'Session initialization failed: ${result.error?.message ?? 'Unknown error'}';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Session initialization crashed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Arculus SDK Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Running on: $_platformVersion\n'),
              Text('Status: $_statusMessage\n'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isInitialized ? _initSession : null,
                child: const Text('Initialize Session'),
              ),
              const SizedBox(height: 20),
              if (_isInitialized) ...[
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _statusMessage = 'Getting firmware version...';
                    });
                    try {
                      final result = await _arculusSdk.getFirmwareVersion();
                      setState(() {
                        _statusMessage = result.isSuccess
                            ? 'Firmware version: ${result.data}'
                            : 'Failed to get firmware version: ${result.error?.message}';
                      });
                    } catch (e) {
                      setState(() {
                        _statusMessage = 'Get firmware version crashed: $e';
                      });
                    }
                  },
                  child: const Text('Get Firmware Version'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _statusMessage = 'Getting GGUID...';
                    });
                    try {
                      final result = await _arculusSdk.getGGUID();
                      setState(() {
                        _statusMessage = result.isSuccess
                            ? 'GGUID: ${result.data}'
                            : 'Failed to get GGUID: ${result.error?.message}';
                      });
                    } catch (e) {
                      setState(() {
                        _statusMessage = 'Get GGUID crashed: $e';
                      });
                    }
                  },
                  child: const Text('Get GGUID'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
