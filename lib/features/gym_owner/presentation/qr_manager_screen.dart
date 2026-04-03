import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers.dart';
import '../models/qr_code_with_image_model.dart';

class QrManagerScreen extends ConsumerStatefulWidget {
  const QrManagerScreen({super.key});

  @override
  ConsumerState<QrManagerScreen> createState() => _QrManagerScreenState();
}

class _QrManagerScreenState extends ConsumerState<QrManagerScreen> {
  bool _generatingOne = false;
  String? _error;
  QrCodeWithImageModel? _latestGenerated;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(gymOwnerControllerProvider.notifier).loadManagedGyms();
    });
  }

  @override
  void dispose() => super.dispose();

  @override
  Widget build(BuildContext context) {
    final ownerState = ref.watch(gymOwnerControllerProvider);
    final gyms = ownerState.gyms;
    final selectedGymId = ownerState.selectedGymId;

    return Scaffold(
      appBar: AppBar(title: const Text('QR Manager')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (ownerState.errorMessage != null)
            Text(ownerState.errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          if (gyms.isEmpty)
            const Text('No managed gyms found.')
          else ...[
            DropdownButtonFormField<int>(
              value: selectedGymId,
              decoration: const InputDecoration(labelText: 'Gym', border: OutlineInputBorder()),
              items: gyms
                  .map(
                    (gym) => DropdownMenuItem<int>(
                      value: gym.id,
                      child: Text(gym.name),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) async {
                if (value == null) {
                  return;
                }
                await ref.read(gymOwnerControllerProvider.notifier).selectGym(value);
                setState(() {
                  _latestGenerated = null;
                });
              },
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: selectedGymId == null || _generatingOne ? null : () => _generateOne(selectedGymId),
              icon: _generatingOne
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.qr_code_2),
              label: const Text('Generate One Dynamic QR'),
            ),
            if (_latestGenerated != null) ...[
              const SizedBox(height: 10),
              const Text('Generated QR (one-time use)', style: TextStyle(fontWeight: FontWeight.bold)),
              _QrCard(item: _latestGenerated!),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _generateOne(int gymId) async {
    setState(() {
      _generatingOne = true;
      _error = null;
    });

    try {
      final api = ref.read(gymOwnerApiProvider);
      final one = await api.generateOneQr(gymId: gymId, size: 260);
      setState(() {
        _latestGenerated = one;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to generate QR';
      });
    } finally {
      if (mounted) {
        setState(() {
          _generatingOne = false;
        });
      }
    }
  }
}

class _QrCard extends StatelessWidget {
  final QrCodeWithImageModel item;

  const _QrCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.gymName, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            SelectableText('Code: ${item.code}'),
            const SizedBox(height: 8),
            Center(
              child: Image.memory(
                base64Decode(item.qrPngBase64),
                width: 180,
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
