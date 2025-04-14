import 'package:flutter/material.dart';
import 'package:kidview/data/models/parent_model.dart';

class ScreenTimeScheduler extends StatefulWidget {
  final List<TimeRange> scheduledTimes;
  final Function(TimeRange) onAddTimeRange;
  final Function(int) onRemoveTimeRange;
  
  const ScreenTimeScheduler({
    super.key,
    required this.scheduledTimes,
    required this.onAddTimeRange,
    required this.onRemoveTimeRange,
  });

  @override
  State<ScreenTimeScheduler> createState() => _ScreenTimeSchedulerState();
}

class _ScreenTimeSchedulerState extends State<ScreenTimeScheduler> {
  final List<String> _daysOfWeek = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  
  String? _selectedDay;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  
  Map<String, List<TimeRange>> get _groupedTimes {
    final Map<String, List<TimeRange>> result = {};
    
    // Initialize with all days of the week
    for (final day in _daysOfWeek) {
      result[day] = [];
    }
    
    // Group schedules by day
    for (final time in widget.scheduledTimes) {
      result[time.dayOfWeek]?.add(time);
    }
    
    return result;
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Screen Time Schedule',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set when your children are allowed to use the app each day',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            
            // Visual weekly calendar
            _buildWeeklyCalendar(),
            
            const SizedBox(height: 16),
            
            // Add new time slot section
            _buildAddTimeSlotSection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWeeklyCalendar() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _daysOfWeek.length,
        separatorBuilder: (context, index) => Divider(height: 1),
        itemBuilder: (context, index) {
          final day = _daysOfWeek[index];
          final timesForDay = _groupedTimes[day] ?? [];
          
          return ExpansionTile(
            title: Row(
              children: [
                Icon(
                  _getDayIcon(day),
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  day,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: timesForDay.isEmpty 
                    ? Colors.grey.shade200 
                    : Theme.of(context).primaryColor.withAlpha(26), // ~0.1 opacity
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                timesForDay.isEmpty 
                    ? 'No schedule' 
                    : '${timesForDay.length} time slot${timesForDay.length > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: timesForDay.isEmpty 
                      ? Colors.grey.shade600
                      : Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            children: [
              if (timesForDay.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No time slots scheduled for $day',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                )
              else
                ...timesForDay.asMap().entries.map((entry) {
                  final index = widget.scheduledTimes.indexOf(entry.value);
                  final time = entry.value;
                  
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    title: Text(
                      '${time.startTime} - ${time.endTime}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => widget.onRemoveTimeRange(index),
                    ),
                  );
                }),
              
              // Add button for this day
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedDay = day;
                  });
                  _showAddTimeDialog();
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Time for this Day'),
              ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildAddTimeSlotSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Add',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select a day and time range to quickly add a scheduled time slot',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        
        // Day selection
        Row(
          children: [
            const Icon(Icons.calendar_today),
            const SizedBox(width: 8),
            Text(
              'Day:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedDay,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDay = newValue;
                  });
                },
                items: _daysOfWeek.map<DropdownMenuItem<String>>((String day) {
                  return DropdownMenuItem<String>(
                    value: day,
                    child: Text(day),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Time range selection
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(Icons.access_time),
                  const SizedBox(width: 8),
                  Text(
                    'From:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final TimeOfDay? time = await showTimePicker(
                          context: context,
                          initialTime: _startTime ?? TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() {
                            _startTime = time;
                          });
                        }
                      },
                      child: Text(
                        _startTime != null 
                            ? _formatTimeOfDay(_startTime!) 
                            : 'Select Start Time',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                children: [
                  const Icon(Icons.access_time),
                  const SizedBox(width: 8),
                  Text(
                    'To:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final TimeOfDay? time = await showTimePicker(
                          context: context,
                          initialTime: _endTime ?? TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() {
                            _endTime = time;
                          });
                        }
                      },
                      child: Text(
                        _endTime != null 
                            ? _formatTimeOfDay(_endTime!) 
                            : 'Select End Time',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Add button
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              onPressed: _canAddTimeRange() ? _addTimeRange : null,
              icon: const Icon(Icons.add),
              label: const Text('Add Time Slot'),
            ),
          ],
        ),
      ],
    );
  }
  
  IconData _getDayIcon(String day) {
    switch (day) {
      case 'Monday':
        return Icons.looks_one;
      case 'Tuesday':
        return Icons.looks_two;
      case 'Wednesday':
        return Icons.looks_3;
      case 'Thursday':
        return Icons.looks_4;
      case 'Friday':
        return Icons.looks_5;
      case 'Saturday':
        return Icons.weekend;
      case 'Sunday':
        return Icons.weekend;
      default:
        return Icons.calendar_today;
    }
  }
  
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  
  bool _canAddTimeRange() {
    return _selectedDay != null && _startTime != null && _endTime != null;
  }
  
  void _addTimeRange() {
    if (_selectedDay != null && _startTime != null && _endTime != null) {
      final newTimeRange = TimeRange(
        dayOfWeek: _selectedDay!,
        startTime: _formatTimeOfDay(_startTime!),
        endTime: _formatTimeOfDay(_endTime!),
      );
      
      widget.onAddTimeRange(newTimeRange);
      
      // Reset form
      setState(() {
        _startTime = null;
        _endTime = null;
      });
    }
  }
  
  Future<void> _showAddTimeDialog() async {
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Add Time for $_selectedDay'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Select the time range when app usage is allowed:'),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Start Time:'),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null) {
                                setState(() {
                                  startTime = time;
                                });
                              }
                            },
                            child: Text(
                              startTime != null 
                                  ? _formatTimeOfDay(startTime!) 
                                  : 'Select Time',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('End Time:'),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null) {
                                setState(() {
                                  endTime = time;
                                });
                              }
                            },
                            child: Text(
                              endTime != null 
                                  ? _formatTimeOfDay(endTime!) 
                                  : 'Select Time',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: startTime != null && endTime != null ? () {
                  final newTimeRange = TimeRange(
                    dayOfWeek: _selectedDay!,
                    startTime: _formatTimeOfDay(startTime!),
                    endTime: _formatTimeOfDay(endTime!),
                  );
                  
                  widget.onAddTimeRange(newTimeRange);
                  Navigator.of(context).pop();
                } : null,
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }
}