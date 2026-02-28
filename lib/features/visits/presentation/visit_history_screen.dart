import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers.dart';
import 'visits_controller.dart';

class VisitHistoryScreen extends ConsumerStatefulWidget {
  const VisitHistoryScreen({super.key});

  @override
  ConsumerState<VisitHistoryScreen> createState() => _VisitHistoryScreenState();
}

class _VisitHistoryScreenState extends ConsumerState<VisitHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(visitsControllerProvider.notifier).loadMyVisits());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(visitsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Visits')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(visitsControllerProvider.notifier).loadMyVisits(),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(VisitsState state) {
    if (state.loading && state.visits.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.visits.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 180),
          Center(child: Text(state.errorMessage!)),
        ],
      );
    }

    if (state.visits.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 180),
          Center(child: Text('No visits found yet')),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: state.visits.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final visit = state.visits[index];
        return Card(
          child: ListTile(
            title: Text(visit.gymName),
            subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(visit.visitedAt)),
            trailing: Text('#${visit.id}'),
          ),
        );
      },
    );
  }
}
