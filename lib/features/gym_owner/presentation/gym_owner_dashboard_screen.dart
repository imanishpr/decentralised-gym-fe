import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../providers.dart';
import '../models/owner_gym_model.dart';

class GymOwnerDashboardScreen extends ConsumerStatefulWidget {
  const GymOwnerDashboardScreen({super.key});

  @override
  ConsumerState<GymOwnerDashboardScreen> createState() => _GymOwnerDashboardScreenState();
}

class _GymOwnerDashboardScreenState extends ConsumerState<GymOwnerDashboardScreen> {
  final _maxDailyController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _mapUrlController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool _active = true;
  TimeOfDay _activeFrom = const TimeOfDay(hour: 5, minute: 0);
  TimeOfDay _activeTo = const TimeOfDay(hour: 23, minute: 0);
  int? _loadedGymId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(gymOwnerControllerProvider.notifier).loadManagedGyms());
  }

  @override
  void dispose() {
    _maxDailyController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _mapUrlController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gymOwnerControllerProvider);
    final selectedGym = state.gyms.where((g) => g.id == state.selectedGymId).firstOrNull;

    if (selectedGym != null && selectedGym.id != _loadedGymId) {
      _loadGymIntoForm(selectedGym);
      _loadedGymId = selectedGym.id;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Owner Dashboard'),
        actions: [
          IconButton(
            onPressed: () => context.push('/profile'),
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
          ),
          IconButton(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(gymOwnerControllerProvider.notifier).loadManagedGyms(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            if (state.loading && state.gyms.isEmpty) const Center(child: CircularProgressIndicator()),
            if (state.errorMessage != null)
              Text(
                state.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const SizedBox(height: 8),
            if (state.gyms.isEmpty)
              const Text('No managed gyms found. Create one from API first.')
            else ...[
              DropdownButtonFormField<int>(
                initialValue: state.selectedGymId,
                decoration: const InputDecoration(labelText: 'Select gym', border: OutlineInputBorder()),
                items: state.gyms
                    .map(
                      (g) => DropdownMenuItem<int>(
                        value: g.id,
                        child: Text(g.name),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  ref.read(gymOwnerControllerProvider.notifier).selectGym(value);
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Gym active'),
                value: _active,
                onChanged: (value) => setState(() => _active = value),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _maxDailyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Max daily visits', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Opening time'),
                subtitle: Text(_formatTime(_activeFrom)),
                trailing: IconButton(onPressed: _pickActiveFrom, icon: const Icon(Icons.schedule)),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Closing time'),
                subtitle: Text(_formatTime(_activeTo)),
                trailing: IconButton(onPressed: _pickActiveTo, icon: const Icon(Icons.schedule)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _latitudeController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: const InputDecoration(labelText: 'Latitude', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _longitudeController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: const InputDecoration(labelText: 'Longitude', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _mapUrlController,
                decoration: const InputDecoration(labelText: 'Google Map URL', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: state.loading || selectedGym == null ? null : () => _save(selectedGym.id),
                child: const Text('Save Gym Settings'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: selectedGym == null ? null : () => context.push('/owner/qr'),
                icon: const Icon(Icons.qr_code_2),
                label: const Text('Open QR Manager'),
              ),
              const SizedBox(height: 16),
              const Text('Users currently inside gym', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (state.currentUsers.isEmpty)
                const Text('No active users inside right now.')
              else
                ...state.currentUsers.map(
                  (user) => Card(
                    child: ListTile(
                      title: Text(user.userName),
                      subtitle: Text('${user.userEmail}\nSlot: ${user.bookingStartTime} - ${user.bookingEndTime}'),
                      isThreeLine: true,
                      trailing: Text(_formatDateTime(user.lastVisitedAt)),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _loadGymIntoForm(OwnerGymModel gym) {
    _active = gym.active;
    _activeFrom = _parseTime(gym.activeFromTime) ?? const TimeOfDay(hour: 5, minute: 0);
    _activeTo = _parseTime(gym.activeToTime) ?? const TimeOfDay(hour: 23, minute: 0);
    _maxDailyController.text = gym.maxDailyVisits.toString();
    _latitudeController.text = gym.latitude?.toString() ?? '';
    _longitudeController.text = gym.longitude?.toString() ?? '';
    _mapUrlController.text = gym.googleMapUrl ?? '';
    _imageUrlController.text = gym.imageUrl ?? '';
  }

  Future<void> _pickActiveFrom() async {
    final picked = await showTimePicker(context: context, initialTime: _activeFrom);
    if (picked != null) {
      setState(() => _activeFrom = picked);
    }
  }

  Future<void> _pickActiveTo() async {
    final picked = await showTimePicker(context: context, initialTime: _activeTo);
    if (picked != null) {
      setState(() => _activeTo = picked);
    }
  }

  Future<void> _save(int gymId) async {
    final maxDaily = int.tryParse(_maxDailyController.text.trim());
    if (maxDaily == null || maxDaily <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid max daily visits')));
      return;
    }

    final latitude = _latitudeController.text.trim().isEmpty ? null : double.tryParse(_latitudeController.text.trim());
    final longitude = _longitudeController.text.trim().isEmpty ? null : double.tryParse(_longitudeController.text.trim());

    await ref.read(gymOwnerControllerProvider.notifier).updateGym(
          gymId: gymId,
          active: _active,
          maxDailyVisits: maxDaily,
          activeFromTime: '${_two(_activeFrom.hour)}:${_two(_activeFrom.minute)}:00',
          activeToTime: '${_two(_activeTo.hour)}:${_two(_activeTo.minute)}:00',
          latitude: latitude,
          longitude: longitude,
          googleMapUrl: _mapUrlController.text.trim().isEmpty ? null : _mapUrlController.text.trim(),
          imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        );

    if (!mounted) {
      return;
    }

    final error = ref.read(gymOwnerControllerProvider).errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Gym updated')));
  }

  TimeOfDay? _parseTime(String raw) {
    final parts = raw.split(':');
    if (parts.length < 2) {
      return null;
    }
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) {
      return null;
    }
    return TimeOfDay(hour: h, minute: m);
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    return DateFormat('HH:mm').format(DateTime(now.year, now.month, now.day, time.hour, time.minute));
  }

  String _formatDateTime(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return raw;
    }
    return DateFormat('HH:mm').format(parsed);
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}

extension _IterableExt<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
