import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers.dart';
import 'stats_controller.dart';

class StreakScreen extends ConsumerStatefulWidget {
  const StreakScreen({super.key});

  @override
  ConsumerState<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends ConsumerState<StreakScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(statsControllerProvider.notifier).loadStreak());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(statsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Streak')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(statsControllerProvider.notifier).loadStreak(),
        child: _buildBody(context, state),
      ),
    );
  }

  Widget _buildBody(BuildContext context, StatsState state) {
    if (state.loading && state.streak == null) {
      return ListView(
        children: const [
          SizedBox(height: 180),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (state.errorMessage != null && state.streak == null) {
      return ListView(
        children: [
          const SizedBox(height: 180),
          Center(child: Text(state.errorMessage!)),
        ],
      );
    }

    final streak = state.streak;
    if (streak == null) {
      return ListView(
        children: const [
          SizedBox(height: 180),
          Center(child: Text('No streak data yet')),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current Streak', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${streak.currentStreak} days', style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            title: const Text('Longest Streak'),
            trailing: Text('${streak.longestStreak} days'),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            title: const Text('Last Visit Date'),
            trailing: Text(
              streak.lastVisitDate == null
                  ? '-' : DateFormat('yyyy-MM-dd').format(streak.lastVisitDate!),
            ),
          ),
        ),
      ],
    );
  }
}
