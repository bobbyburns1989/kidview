import 'package:flutter/material.dart';

class TimeRangePicker extends StatefulWidget {
  final List<String> days;

  const TimeRangePicker({
    super.key,
    required this.days,
  });

  @override
  State<TimeRangePicker> createState() => _TimeRangePickerState();
}

class _TimeRangePickerState extends State<TimeRangePicker> {
  String _selectedDay = '';
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.days.first;
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
        
        // Ensure end time is after start time
        if (_endTime.hour < _startTime.hour || 
            (_endTime.hour == _startTime.hour && _endTime.minute < _startTime.minute)) {
          // Set end time to be 1 hour after start time
          _endTime = TimeOfDay(
            hour: (_startTime.hour + 1) % 24,
            minute: _startTime.minute,
          );
        }
      });
    }
  }

  Future<void> _selectEndTime() async {
    // Store scaffold messenger before async operation
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    
    if (!context.mounted) return;
    
    if (picked != null && picked != _endTime) {
      // Validate that end time is after start time
      if (picked.hour < _startTime.hour || 
          (picked.hour == _startTime.hour && picked.minute <= _startTime.minute)) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('End time must be after start time')),
        );
        return;
      }
      
      setState(() {
        _endTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Allowed Viewing Time'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select day:'),
            const SizedBox(height: 8),
            // Day selection dropdown
            DropdownButtonFormField<String>(
              value: _selectedDay,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: widget.days.map((String day) {
                return DropdownMenuItem<String>(
                  value: day,
                  child: Text(day),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedDay = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            const Text('Select time range:'),
            const SizedBox(height: 8),
            // Time range selection
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _selectStartTime,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        labelText: 'Start',
                      ),
                      child: Text(_formatTimeOfDay(_startTime)),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('to'),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _selectEndTime,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        labelText: 'End',
                      ),
                      child: Text(_formatTimeOfDay(_endTime)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop({
              'day': _selectedDay,
              'start': _formatTimeOfDay(_startTime),
              'end': _formatTimeOfDay(_endTime),
            });
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hour.toString().padLeft(2, '0');
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}