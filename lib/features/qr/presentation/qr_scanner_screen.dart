import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../providers.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final _manualCodeController = TextEditingController();
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isHandlingScan = false;
  bool _scanCompleted = false;
  bool _showSuccess = false;

  @override
  void dispose() {
    _scannerController.dispose();
    _manualCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(qrControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Visit Code')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 260,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: MobileScanner(
                  controller: _scannerController,
                  onDetect: (capture) {
                    if (_isHandlingScan || _scanCompleted) {
                      return;
                    }
                    final code = capture.barcodes.first.rawValue;
                    if (code != null && code.isNotEmpty) {
                      _isHandlingScan = true;
                      _manualCodeController.text = code;
                      _handleScan(code);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _manualCodeController,
              decoration: const InputDecoration(
                labelText: 'Manual code entry',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: state.loading || _scanCompleted
                  ? null
                  : () => _handleScan(_manualCodeController.text),
              child: const Text('Confirm scan'),
            ),
            if (_showSuccess) ...[
              const SizedBox(height: 12),
              const Center(
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48,
                ),
              ),
            ],
            if (state.loading) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
            if (state.result != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Visit confirmed', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Gym: ${state.result!.gymName}'),
                      Text('Visit ID: ${state.result!.visitId}'),
                      Text('Booking ID: ${state.result!.bookingId}'),
                      Text('Visited At: ${DateFormat('yyyy-MM-dd HH:mm').format(state.result!.visitedAt)}'),
                      Text('Current streak: ${state.result!.currentStreak}'),
                      Text('Longest streak: ${state.result!.longestStreak}'),
                    ],
                  ),
                ),
              ),
            ],
            if (state.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                state.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleScan(String code) async {
    if (_scanCompleted || code.trim().isEmpty) {
      return;
    }

    _isHandlingScan = true;
    await ref.read(qrControllerProvider.notifier).scanCode(code);
    final updatedState = ref.read(qrControllerProvider);

    if (!mounted) {
      return;
    }

    if (updatedState.result != null) {
      await _scannerController.stop();
      setState(() {
        _scanCompleted = true;
        _showSuccess = true;
      });

      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (mounted) {
        context.push('/streak');
      }
      return;
    }

    _isHandlingScan = false;
  }
}
