import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers.dart';
import '../../../shared/models/booking_model.dart';
import 'booking_controller.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(bookingControllerProvider.notifier).loadMyBookings());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(bookingControllerProvider.notifier).loadMyBookings(),
        child: _buildBody(context, state),
      ),
    );
  }

  Widget _buildBody(BuildContext context, BookingState state) {
    if (state.loading && state.bookings.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 180),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (state.errorMessage != null && state.bookings.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 180),
          Center(child: Text(state.errorMessage!)),
        ],
      );
    }

    if (state.bookings.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 180),
          Center(child: Text('No bookings found')),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: state.bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final booking = state.bookings[index];
        return _BookingCard(
          booking: booking,
          loading: state.loading,
          onEdit: booking.status == 'CREATED' ? () => _editBooking(booking) : null,
          onDelete: booking.status == 'CREATED' ? () => _deleteBooking(booking.id) : null,
        );
      },
    );
  }

  Future<void> _editBooking(BookingModel booking) async {
    final result = await showModalBottomSheet<_EditResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EditBookingSheet(initial: booking),
    );

    if (result == null) {
      return;
    }

    await ref.read(bookingControllerProvider.notifier).updateBooking(
          bookingId: booking.id,
          bookingDate: DateFormat('yyyy-MM-dd').format(result.date),
          startTime: '${_two(result.startTime.hour)}:${_two(result.startTime.minute)}:00',
          durationHours: result.durationHours,
          note: result.note,
        );

    if (!mounted) {
      return;
    }

    final error = ref.read(bookingControllerProvider).errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Booking updated')),
    );
  }

  Future<void> _deleteBooking(int bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete booking?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await ref.read(bookingControllerProvider.notifier).deleteBooking(bookingId);

    if (!mounted) {
      return;
    }

    final error = ref.read(bookingControllerProvider).errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Booking deleted')),
    );
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final bool loading;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _BookingCard({
    required this.booking,
    required this.loading,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bookingDate = DateFormat('yyyy-MM-dd').format(booking.bookingDate);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(booking.gymName, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Date: $bookingDate'),
            Text('Time: ${booking.startTime ?? '-'} - ${booking.endTime ?? '-'}'),
            Text('Duration: ${booking.durationHours ?? '-'} hour(s)'),
            Text('Status: ${booking.status}'),
            if (booking.note != null && booking.note!.isNotEmpty) Text('Note: ${booking.note}'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: loading ? null : onEdit,
                    child: const Text('Update'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: loading ? null : onDelete,
                    style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EditResult {
  final DateTime date;
  final TimeOfDay startTime;
  final int durationHours;
  final String? note;

  const _EditResult({
    required this.date,
    required this.startTime,
    required this.durationHours,
    required this.note,
  });
}

class _EditBookingSheet extends StatefulWidget {
  final BookingModel initial;

  const _EditBookingSheet({required this.initial});

  @override
  State<_EditBookingSheet> createState() => _EditBookingSheetState();
}

class _EditBookingSheetState extends State<_EditBookingSheet> {
  late DateTime _date;
  late TimeOfDay _startTime;
  int _durationHours = 1;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _date = widget.initial.bookingDate;
    _startTime = _parseTime(widget.initial.startTime) ?? TimeOfDay.now();
    _durationHours = widget.initial.durationHours ?? 1;
    _noteController = TextEditingController(text: widget.initial.note ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Update booking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date'),
            subtitle: Text(DateFormat('yyyy-MM-dd').format(_date)),
            trailing: IconButton(onPressed: _pickDate, icon: const Icon(Icons.date_range)),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Start time'),
            subtitle: Text(_formatTime(_startTime)),
            trailing: IconButton(onPressed: _pickTime, icon: const Icon(Icons.schedule)),
          ),
          DropdownButtonFormField<int>(
            value: _durationHours,
            decoration: const InputDecoration(labelText: 'Duration'),
            items: const [
              DropdownMenuItem(value: 1, child: Text('1 hour')),
              DropdownMenuItem(value: 2, child: Text('2 hours')),
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() {
                _durationHours = value;
              });
            },
          ),
          const SizedBox(height: 8),
          Text('End time: ${_formatTime(_calculateEndTime())}'),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            maxLength: 500,
            decoration: const InputDecoration(labelText: 'Note (optional)'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: _submit,
                  child: const Text('Save'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _startTime);
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  void _submit() {
    final total = (_startTime.hour * 60) + _startTime.minute + (_durationHours * 60);
    if (total >= 24 * 60) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected slot crosses midnight. Pick an earlier start time.')),
      );
      return;
    }

    Navigator.pop(
      context,
      _EditResult(
        date: _date,
        startTime: _startTime,
        durationHours: _durationHours,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      ),
    );
  }

  TimeOfDay _calculateEndTime() {
    final totalMinutes = (_startTime.hour * 60) + _startTime.minute + (_durationHours * 60);
    return TimeOfDay(hour: (totalMinutes ~/ 60) % 24, minute: totalMinutes % 60);
  }

  TimeOfDay? _parseTime(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final parts = value.split(':');
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
}
