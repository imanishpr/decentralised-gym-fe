import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../providers.dart';
import '../../../shared/models/gym_model.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final GymModel gym;

  const BookingScreen({super.key, required this.gym});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  int _durationHours = 1;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Book ${widget.gym.name}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.gym.address),
            Text(widget.gym.city),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Booking date'),
              subtitle: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
              trailing: IconButton(
                icon: const Icon(Icons.date_range),
                onPressed: _pickDate,
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Start time'),
              subtitle: Text(_formatTimeOfDay(_startTime)),
              trailing: IconButton(
                icon: const Icon(Icons.schedule),
                onPressed: _pickStartTime,
              ),
            ),
            DropdownButtonFormField<int>(
              value: _durationHours,
              items: const [
                DropdownMenuItem(value: 1, child: Text('1 hour')),
                DropdownMenuItem(value: 2, child: Text('2 hours')),
              ],
              decoration: const InputDecoration(
                labelText: 'Duration',
                border: OutlineInputBorder(),
              ),
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
            Text(
              'End time: ${_formatTimeOfDay(_calculateEndTime())}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLength: 500,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: bookingState.loading ? null : _submitBooking,
              child: const Text('Create booking'),
            ),
            if (bookingState.loading) ...[
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
            ],
            if (bookingState.latestBooking != null) ...[
              const SizedBox(height: 16),
              Text('Booking created with ID: ${bookingState.latestBooking!.id}'),
            ],
            if (bookingState.errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                bookingState.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.push('/my-bookings'),
                    child: const Text('My bookings'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.push('/scan'),
                    child: const Text('Go to scanner'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 0)),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );

    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _submitBooking() async {
    final endCrossesMidnight = (_startTime.hour * 60) + _startTime.minute + (_durationHours * 60) >= (24 * 60);
    if (endCrossesMidnight) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected slot crosses midnight. Pick an earlier start time.')),
      );
      return;
    }

    final date = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final startTime = '${_two(_startTime.hour)}:${_two(_startTime.minute)}:00';
    await ref.read(bookingControllerProvider.notifier).createBooking(
          gymId: widget.gym.id,
          bookingDate: date,
          startTime: startTime,
          durationHours: _durationHours,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        );
  }

  TimeOfDay _calculateEndTime() {
    final totalMinutes = (_startTime.hour * 60) + _startTime.minute + (_durationHours * 60);
    final endHour = (totalMinutes ~/ 60) % 24;
    final endMinute = totalMinutes % 60;
    return TimeOfDay(hour: endHour, minute: endMinute);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final asDate = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(asDate);
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}
