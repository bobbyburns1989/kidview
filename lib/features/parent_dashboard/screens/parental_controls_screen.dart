import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:kidview/data/providers/auth_provider.dart';
import 'package:kidview/data/models/parent_model.dart';
import 'package:kidview/core/constants/route_constants.dart';
import 'package:kidview/features/parent_dashboard/widgets/section_header.dart';
import 'package:kidview/features/parent_dashboard/widgets/time_range_picker.dart';
// import 'package:kidview/features/parent_dashboard/widgets/screen_time_dashboard.dart';
import 'package:kidview/features/parent_dashboard/widgets/screen_time_scheduler.dart';
import 'package:kidview/features/parent_dashboard/widgets/screen_time_monitor.dart';
import 'package:kidview/features/parent_dashboard/widgets/content_filter_visualization.dart';
import 'package:kidview/features/parent_dashboard/widgets/pin_management.dart';
import 'package:kidview/features/parent_dashboard/widgets/child_content_filter_settings.dart';
// import 'package:kidview/features/parent_dashboard/widgets/weekly_report_generator.dart';
import 'package:kidview/data/services/usage_tracking_service.dart';
// import 'dart:math' as math;
import 'package:kidview/features/parent_dashboard/screens/screen_time_utils.dart';

class ParentalControlsScreen extends StatefulWidget {
  const ParentalControlsScreen({super.key});

  @override
  State<ParentalControlsScreen> createState() => _ParentalControlsScreenState();
}

class _ParentalControlsScreenState extends State<ParentalControlsScreen> {
  bool _isLoading = false;
  late ParentalControls _controls;
  final List<String> _dayOfWeek = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  // Initialize usage tracking service
  final UsageTrackingService _usageService = UsageTrackingService();

  @override
  void initState() {
    super.initState();
    // Initialize with current values from provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.parent != null) {
      _controls = authProvider.parent!.controls;
      // Initialize usage tracking with demo data
      _usageService.initializeDemoData(authProvider.parent!.children);
    } else {
      // Fallback defaults if somehow there's no parent (shouldn't happen)
      _controls = ParentalControls(
        pinProtected: false,
        pin: '0000',
        allowDownloads: true,
        preventAppSwitching: false,
        scheduledViewingTimes: [],
        contentFilters: {
          'violence': true,
          'language': true,
          'fear': true,
          'consumerism': true,
        },
      );
    }
  }

  Future<void> _saveControls() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.updateControls(_controls);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Parental controls updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update parental controls: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addScheduledTime() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => TimeRangePicker(
        days: _dayOfWeek,
      ),
    );
    
    if (result != null) {
      final newTimeRange = TimeRange(
        dayOfWeek: result['day']!,
        startTime: result['start']!,
        endTime: result['end']!,
      );
      
      _addTimeRange(newTimeRange);
    }
  }
  
  void _addTimeRange(TimeRange newTimeRange) {
    setState(() {
      final newTimes = [..._controls.scheduledViewingTimes, newTimeRange];
      _controls = ParentalControls(
        pinProtected: _controls.pinProtected,
        pin: _controls.pin,
        allowDownloads: _controls.allowDownloads,
        preventAppSwitching: _controls.preventAppSwitching,
        scheduledViewingTimes: newTimes,
        contentFilters: _controls.contentFilters,
      );
    });
    _saveControls();
  }

  void _removeScheduledTime(int index) {
    setState(() {
      final newTimes = List<TimeRange>.from(_controls.scheduledViewingTimes);
      newTimes.removeAt(index);
      _controls = ParentalControls(
        pinProtected: _controls.pinProtected,
        pin: _controls.pin,
        allowDownloads: _controls.allowDownloads,
        preventAppSwitching: _controls.preventAppSwitching,
        scheduledViewingTimes: newTimes,
        contentFilters: _controls.contentFilters,
      );
    });
    _saveControls();
  }

  void _updateContentFilter(String filterKey, bool value) {
    setState(() {
      final updatedFilters = Map<String, bool>.from(_controls.contentFilters);
      updatedFilters[filterKey] = value;
      
      _controls = ParentalControls(
        pinProtected: _controls.pinProtected,
        pin: _controls.pin,
        allowDownloads: _controls.allowDownloads,
        preventAppSwitching: _controls.preventAppSwitching,
        scheduledViewingTimes: _controls.scheduledViewingTimes,
        contentFilters: updatedFilters,
      );
    });
    _saveControls();
  }

  void _togglePinProtection(bool value) {
    setState(() {
      _controls = ParentalControls(
        pinProtected: value,
        pin: _controls.pin,
        allowDownloads: _controls.allowDownloads,
        preventAppSwitching: _controls.preventAppSwitching,
        scheduledViewingTimes: _controls.scheduledViewingTimes,
        contentFilters: _controls.contentFilters,
      );
    });
    _saveControls();
  }
  
  void _changePin(String newPin) {
    setState(() {
      _controls = ParentalControls(
        pinProtected: _controls.pinProtected,
        pin: newPin,
        allowDownloads: _controls.allowDownloads,
        preventAppSwitching: _controls.preventAppSwitching,
        scheduledViewingTimes: _controls.scheduledViewingTimes,
        contentFilters: _controls.contentFilters,
      );
    });
    _saveControls();
  }

  void _toggleAllowDownloads(bool value) {
    setState(() {
      _controls = ParentalControls(
        pinProtected: _controls.pinProtected,
        pin: _controls.pin,
        allowDownloads: value,
        preventAppSwitching: _controls.preventAppSwitching,
        scheduledViewingTimes: _controls.scheduledViewingTimes,
        contentFilters: _controls.contentFilters,
      );
    });
    _saveControls();
  }

  void _togglePreventAppSwitching(bool value) {
    setState(() {
      _controls = ParentalControls(
        pinProtected: _controls.pinProtected,
        pin: _controls.pin,
        allowDownloads: _controls.allowDownloads,
        preventAppSwitching: value,
        scheduledViewingTimes: _controls.scheduledViewingTimes,
        contentFilters: _controls.contentFilters,
      );
    });
    _saveControls();
  }

  // Function to show per-child content filter settings
  void _showChildFilterSettings(BuildContext context, Child child) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ChildContentFilterSettings(
          child: child,
          globalFilters: _controls.contentFilters,
          onChildUpdated: _updateChildProfile,
        ),
      ),
    );
  }
  
  // Update child profile
  Future<void> _updateChildProfile(Child updatedChild) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.updateChild(updatedChild);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final children = authProvider.parent?.children ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parental Controls'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.parentHome),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Material(
              color: Theme.of(context).primaryColor,
              child: TabBar(
                tabs: const [
                  Tab(text: 'Controls'),
                  Tab(text: 'Screen Time'),
                  Tab(text: 'Content'),
                ],
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: General Controls
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Security section
                        const SectionHeader(title: 'Security'),
                        PinManagement(
                          controls: _controls,
                          onTogglePinProtection: _togglePinProtection,
                          onPinChanged: _changePin,
                        ),
                        const SizedBox(height: 24),
                        
                        // Schedule section
                        const SectionHeader(title: 'Viewing Schedule'),
                        _buildScheduleSection(),
                        const SizedBox(height: 24),
                        
                        // Miscellaneous settings section
                        const SectionHeader(title: 'Advanced Settings'),
                        _buildAdvancedSettingsSection(),
                        
                        // Resources section
                        const SizedBox(height: 24),
                        const SectionHeader(title: 'Resources'),
                        _buildResourcesSection(),
                      ],
                    ),
                  ),
                  
                  // Tab 2: Screen Time Tracking
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Screen time monitor with enhanced visualization
                        const SectionHeader(title: 'Screen Time Usage'),
                        ScreenTimeMonitor(
                          children: children,
                          onViewWeeklyReport: () => _showWeeklyReport(context, children),
                          onEditTimeLimit: (child) => _showTimeUpdateDialog(context, child),
                        ),
                        const SizedBox(height: 24),
                        
                        // Enhanced screen time scheduler
                        const SectionHeader(title: 'Screen Time Schedule'),
                        ScreenTimeScheduler(
                          scheduledTimes: _controls.scheduledViewingTimes,
                          onAddTimeRange: _addTimeRange,
                          onRemoveTimeRange: _removeScheduledTime,
                        ),
                        const SizedBox(height: 24),
                        
                        // Individual limits section
                        const SectionHeader(title: 'Screen Time Limits'),
                        _buildScreenTimeLimitsSection(children),
                      ],
                    ),
                  ),
                  
                  // Tab 3: Content Filtering
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Global content filtering
                        const SectionHeader(title: 'Global Content Filters'),
                        ContentFilterVisualization(
                          filters: _controls.contentFilters,
                          filterLabels: {
                            'violence': 'Block violent content',
                            'language': 'Block strong language',
                            'fear': 'Block scary content',
                            'consumerism': 'Block commercial/advertising content',
                          },
                          onFilterChanged: _updateContentFilter,
                        ),
                        const SizedBox(height: 24),
                        
                        // Per-child content filters
                        const SectionHeader(title: 'Child-Specific Filters'),
                        _buildPerChildFiltersSection(children),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scheduled Viewing Times',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Set times when your children are allowed to use the app',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            
            // List of scheduled times
            if (_controls.scheduledViewingTimes.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text(
                    'No scheduled viewing times set',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _controls.scheduledViewingTimes.length,
                itemBuilder: (context, index) {
                  final timeRange = _controls.scheduledViewingTimes[index];
                  return Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surface,
                    child: ListTile(
                      leading: Icon(
                        _getDayIcon(timeRange.dayOfWeek),
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(timeRange.dayOfWeek),
                      subtitle: Text('${timeRange.startTime} - ${timeRange.endTime}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _removeScheduledTime(index),
                      ),
                    ),
                  );
                },
              ),
            
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: _addScheduledTime,
                icon: const Icon(Icons.add),
                label: const Text('Add Allowed Time'),
              ),
            ),
          ],
        ),
      ),
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
  
  Widget _buildScreenTimeLimitsSection(List<Child> children) {
    return ScreenTimeUtils.buildScreenTimeLimitsSection(
      context, 
      children,
      _updateChildProfile,
    );
  }
  
  void _showTimeUpdateDialog(BuildContext context, Child child) {
    ScreenTimeUtils.showTimeUpdateDialog(context, child, _updateChildProfile);
  }
  
  Widget _buildPerChildFiltersSection(List<Child> children) {
    if (children.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  'No children profiles available',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add a child profile to set individual content filters',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Per-Child Content Filtering',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Customize content filters for each child based on their needs',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            
            // Child list with filter status
            ...children.map((child) {
              // Determine if child has custom filters
              final hasCustomFilters = child.contentTags.isNotEmpty;
              
              return Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: hasCustomFilters 
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                      child: Icon(
                        hasCustomFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(child.name),
                    subtitle: Text(
                      hasCustomFilters 
                          ? 'Using custom content filters'
                          : 'Using global content filters',
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _showChildFilterSettings(context, child),
                      child: const Text('Configure'),
                    ),
                  ),
                  const Divider(),
                ],
              );
            }),
            
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, 
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Custom filters allow you to tailor content restrictions based on each child\'s maturity level and sensitivity.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAdvancedSettingsSection() {
    return ScreenTimeUtils.buildAdvancedSettingsSection(
      context,
      _controls,
      _toggleAllowDownloads,
      _togglePreventAppSwitching,
    );
  }
  
  Widget _buildResourcesSection() {
    return ScreenTimeUtils.buildResourcesSection(context);
  }
  
  // Show weekly report
  void _showWeeklyReport(BuildContext context, List<Child> children) {
    ScreenTimeUtils.showWeeklyReport(context, children);
  }
}