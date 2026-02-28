import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User profile not available')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundImage: (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty)
                  ? NetworkImage(user.profileImageUrl!)
                  : null,
              child: (user.profileImageUrl == null || user.profileImageUrl!.isEmpty)
                  ? Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          _InfoCard(title: 'Name', value: user.name),
          _InfoCard(title: 'Email', value: user.email),
          _InfoCard(title: 'Role', value: user.role),
          _InfoCard(title: 'Provider', value: user.provider),
          _InfoCard(title: 'Provider User ID', value: user.providerUserId),
          _InfoCard(title: 'Joined On', value: DateFormat('yyyy-MM-dd HH:mm').format(user.createdAt.toLocal())),
          if (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty)
            _InfoCard(title: 'Profile Image URL', value: user.profileImageUrl!),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const _InfoCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(value.isEmpty ? '-' : value),
      ),
    );
  }
}
