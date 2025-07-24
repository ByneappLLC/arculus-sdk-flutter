import 'package:flutter/material.dart';
import 'package:arculus_sdk/arculus_sdk.dart';

/// Example demonstrating FFI-based Arculus SDK usage
class FFIExample extends StatefulWidget {
  const FFIExample({super.key});

  @override
  State<FFIExample> createState() => _FFIExampleState();
}

class _FFIExampleState extends State<FFIExample> {
  String _status = 'Not initialized';
  Map<String, dynamic>? _lastResult;
  bool _isFFIMode = false;

  @override
  void initState() {
    super.initState();
    _checkFFISupport();
  }

  void _checkFFISupport() {
    setState(() {
      _status = isFFISupported()
          ? 'FFI supported on this platform'
          : 'FFI not supported, using platform channels';
    });
  }

  Future<void> _initializeFFI() async {
    try {
      await initializeArculusSDKFFI();
      setState(() {
        _status = 'FFI initialized successfully';
        _isFFIMode = true;
      });
    } catch (e) {
      setState(() {
        _status = 'FFI initialization failed: $e';
      });
    }
  }

  Future<void> _performSDKOperation(String operation) async {
    try {
      final sdk = ArculusSdk();
      Map<String, dynamic> result;

      switch (operation) {
        case 'initSession':
          final initResult = await sdk.initSession();
          result = {
            'success': initResult.isSuccess,
            'error': initResult.error?.message,
          };
          break;
        case 'createWallet':
          final createResult = await sdk.createWallet();
          result = {
            'success': createResult.isSuccess,
            'mnemonic': createResult.data?.mnemonic,
            'error': createResult.error?.message,
          };
          break;
        case 'getPublicKey':
          final pubKeyResult = await sdk.getPublicKey("m/44'/60'/0'/0/0");
          result = {
            'success': pubKeyResult.isSuccess,
            'publicKey': pubKeyResult.data?.publicKey,
            'chainCode': pubKeyResult.data?.chainCode,
            'error': pubKeyResult.error?.message,
          };
          break;
        case 'getFirmwareVersion':
          final firmwareResult = await sdk.getFirmwareVersion();
          result = {
            'success': firmwareResult.isSuccess,
            'version': firmwareResult.data,
            'error': firmwareResult.error?.message,
          };
          break;
        case 'getGGUID':
          final gguidResult = await sdk.getGGUID();
          result = {
            'success': gguidResult.isSuccess,
            'gguid': gguidResult.data,
            'error': gguidResult.error?.message,
          };
          break;
        default:
          result = {'error': 'Unknown operation'};
      }

      setState(() {
        _lastResult = result;
        _status = 'Operation completed: $operation';
      });
    } catch (e) {
      setState(() {
        _status = 'Operation failed: $e';
        _lastResult = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arculus SDK FFI Example'),
        backgroundColor: _isFFIMode ? Colors.green : Colors.blue,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: isFFISupported() ? _initializeFFI : null,
                          child: const Text('Initialize FFI'),
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(
                              _isFFIMode ? 'FFI Mode' : 'Platform Channel'),
                          backgroundColor: _isFFIMode
                              ? Colors.green.shade100
                              : Colors.blue.shade100,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SDK Operations',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: () => _performSDKOperation('initSession'),
                          child: const Text('Init Session'),
                        ),
                        ElevatedButton(
                          onPressed: () => _performSDKOperation('createWallet'),
                          child: const Text('Create Wallet'),
                        ),
                        ElevatedButton(
                          onPressed: () => _performSDKOperation('getPublicKey'),
                          child: const Text('Get Public Key'),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              _performSDKOperation('getFirmwareVersion'),
                          child: const Text('Get Firmware'),
                        ),
                        ElevatedButton(
                          onPressed: () => _performSDKOperation('getGGUID'),
                          child: const Text('Get GGUID'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_lastResult != null)
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last Result',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            child: SelectableText(
                              _formatResult(_lastResult!),
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatResult(Map<String, dynamic> result) {
    final buffer = StringBuffer();
    result.forEach((key, value) {
      buffer.writeln('$key: $value');
    });
    return buffer.toString();
  }
}

/// Performance comparison widget
class PerformanceComparison extends StatefulWidget {
  const PerformanceComparison({super.key});

  @override
  State<PerformanceComparison> createState() => _PerformanceComparisonState();
}

class _PerformanceComparisonState extends State<PerformanceComparison> {
  final List<BenchmarkResult> _results = [];
  bool _running = false;

  Future<void> _runBenchmark() async {
    setState(() {
      _running = true;
      _results.clear();
    });

    try {
      // Benchmark platform channel implementation
      final platformChannelTime = await _benchmarkImplementation(false);

      // Benchmark FFI implementation
      await initializeArculusSDKFFI();
      final ffiTime = await _benchmarkImplementation(true);

      setState(() {
        _results.addAll([
          BenchmarkResult('Platform Channel', platformChannelTime),
          BenchmarkResult('FFI', ffiTime),
        ]);
      });
    } finally {
      setState(() {
        _running = false;
      });
    }
  }

  Future<int> _benchmarkImplementation(bool useFFI) async {
    const iterations = 10;
    final stopwatch = Stopwatch()..start();

    final sdk = ArculusSdk();

    for (int i = 0; i < iterations; i++) {
      await sdk.getFirmwareVersion();
    }

    stopwatch.stop();
    return stopwatch.elapsedMilliseconds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Comparison'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _running ? null : _runBenchmark,
              child: _running
                  ? const CircularProgressIndicator()
                  : const Text('Run Benchmark'),
            ),
            const SizedBox(height: 16),
            if (_results.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final result = _results[index];
                    return Card(
                      child: ListTile(
                        title: Text(result.implementation),
                        trailing: Text('${result.timeMs}ms'),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class BenchmarkResult {
  final String implementation;
  final int timeMs;

  BenchmarkResult(this.implementation, this.timeMs);
}
