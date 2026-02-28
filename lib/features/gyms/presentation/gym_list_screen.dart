import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../providers.dart';
import '../../../shared/models/gym_model.dart';
import 'gym_controller.dart';

class GymListScreen extends ConsumerStatefulWidget {
  const GymListScreen({super.key});

  @override
  ConsumerState<GymListScreen> createState() => _GymListScreenState();
}

class _GymListScreenState extends ConsumerState<GymListScreen> {
  Position? _currentPosition;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(gymControllerProvider.notifier).loadGyms();
      await _loadCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final gymState = ref.watch(gymControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Gyms'),
        actions: [
          IconButton(
            onPressed: () => context.push('/profile'),
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
          ),
          IconButton(
            onPressed: () => context.push('/my-bookings'),
            icon: const Icon(Icons.event_note),
            tooltip: 'My bookings',
          ),
          IconButton(
            onPressed: () => context.push('/visits'),
            icon: const Icon(Icons.history),
            tooltip: 'Visit history',
          ),
          IconButton(
            onPressed: () => context.push('/streak'),
            icon: const Icon(Icons.local_fire_department),
            tooltip: 'My streak',
          ),
          IconButton(
            onPressed: () => context.push('/scan'),
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan code',
          ),
          IconButton(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (authState.user != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text('Welcome ${authState.user!.name}'),
            ),
          if (_locationError != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                _locationError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(gymControllerProvider.notifier).loadGyms();
                await _loadCurrentLocation();
              },
              child: _buildList(context, gymState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, GymListState state) {
    if (state.loading && state.gyms.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.gyms.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 160),
          Center(child: Text(state.errorMessage!)),
        ],
      );
    }

    if (state.gyms.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 160),
          Center(child: Text('No active gyms available')),
        ],
      );
    }

    final sortedGyms = [...state.gyms]
      ..sort((a, b) {
        final d1 = _distanceKm(a);
        final d2 = _distanceKm(b);
        if (d1 == null && d2 == null) {
          return a.name.compareTo(b.name);
        }
        if (d1 == null) {
          return 1;
        }
        if (d2 == null) {
          return -1;
        }
        return d1.compareTo(d2);
      });

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: sortedGyms.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final gym = sortedGyms[index];
        return _GymCard(
          gym: gym,
          distanceKm: _distanceKm(gym),
          onNavigate: gym.googleMapUrl == null || gym.googleMapUrl!.isEmpty
              ? null
              : () => _openMapUrl(gym.googleMapUrl!),
        );
      },
    );
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'Location is disabled. Enable it to see nearest gyms.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'Location permission denied. Distance is unavailable.';
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) {
        return;
      }
      setState(() {
        _currentPosition = pos;
        _locationError = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _locationError = 'Unable to access location right now.';
      });
    }
  }

  double? _distanceKm(GymModel gym) {
    if (_currentPosition == null || gym.latitude == null || gym.longitude == null) {
      return null;
    }
    final meters = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      gym.latitude!,
      gym.longitude!,
    );
    return meters / 1000.0;
  }

  Future<void> _openMapUrl(String rawUrl) async {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid map URL')));
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open map URL')));
    }
  }
}

class _GymCard extends StatelessWidget {
  final GymModel gym;
  final double? distanceKm;
  final VoidCallback? onNavigate;

  const _GymCard({
    required this.gym,
    required this.distanceKm,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (gym.imageUrl != null && gym.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  gym.imageUrl!,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            if (gym.imageUrl != null && gym.imageUrl!.isNotEmpty) const SizedBox(height: 10),
            Text(gym.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${gym.address}, ${gym.city}'),
            if (gym.pricePerHourInr != null)
              Text('Price: INR ${gym.pricePerHourInr!.toStringAsFixed(0)} / hour'),
            if (gym.activeFromTime != null && gym.activeToTime != null)
              Text('Timings: ${_hhmm(gym.activeFromTime!)} - ${_hhmm(gym.activeToTime!)}'),
            if (distanceKm != null) Text('Distance: ${distanceKm!.toStringAsFixed(1)} km'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => context.push('/booking', extra: gym),
                    child: const Text('Book'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onNavigate,
                    child: const Text('Navigate'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _hhmm(String raw) {
    final parts = raw.split(':');
    if (parts.length < 2) {
      return raw;
    }
    return '${parts[0]}:${parts[1]}';
  }
}
