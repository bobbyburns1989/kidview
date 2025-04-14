import 'package:flutter/material.dart';
import 'package:kidview/config/themes.dart';
import 'package:kidview/data/models/parent_model.dart';
import 'package:kidview/data/services/usage_tracking_service.dart';
import 'dart:math' as math;

class WeeklyReportGenerator extends StatefulWidget {
  final List<Child> children;
  
  const WeeklyReportGenerator({
    super.key,
    required this.children,
  });

  @override
  State<WeeklyReportGenerator> createState() => _WeeklyReportGeneratorState();
}

class _WeeklyReportGeneratorState extends State<WeeklyReportGenerator> {
  final UsageTrackingService _usageService = UsageTrackingService();
  String? _selectedChildId;
  late ScreenTimeReport _report;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize demo data
    _usageService.initializeDemoData(widget.children);
    
    // Select first child by default if available
    if (widget.children.isNotEmpty) {
      _selectedChildId = widget.children[0].id;
      _report = _usageService.generateReport(_selectedChildId!);
    }
  }

  void _selectChild(String childId) {
    setState(() {
      _selectedChildId = childId;
      _report = _usageService.generateReport(childId);
    });
  }

  void _generateReport() {
    if (_selectedChildId == null) return;
    
    setState(() {
      _isGenerating = true;
    });
    
    // Store scaffold messenger before async operation
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Simulate report generation (would fetch data in a real app)
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _report = _usageService.generateReport(_selectedChildId!);
          _isGenerating = false;
        });
        
        // Show success message using stored reference
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Report generated successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bar_chart,
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
                  'Add a child profile to generate usage reports',
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
            Text(
              'Weekly Screen Time Report',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Child selection
            _buildChildSelector(),
            const SizedBox(height: 24),
            
            // Report content
            if (_selectedChildId != null) _buildReportContent(),
            
            // Generate button
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateReport,
                icon: _isGenerating 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.refresh),
                label: Text(_isGenerating ? 'Generating...' : 'Generate Report'),
              ),
            ),
            Center(
              child: TextButton.icon(
                onPressed: _isGenerating 
                    ? null 
                    : () => _showFullReport(context),
                icon: const Icon(Icons.open_in_new),
                label: const Text('View Full Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChildSelector() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Select Child',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      value: _selectedChildId,
      items: widget.children.map((child) {
        return DropdownMenuItem<String>(
          value: child.id,
          child: Text(child.name),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          _selectChild(value);
        }
      },
    );
  }
  
  Widget _buildReportContent() {
    final selectedChild = widget.children.firstWhere(
      (child) => child.id == _selectedChildId,
    );
    
    final weeklyUsage = _report.weeklyUsage;
    final dailyLimit = selectedChild.dailyTimeLimit;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppThemes.withTransparency(Theme.of(context).primaryColor, 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weekly Summary for ${selectedChild.name}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              _buildSummaryRow(
                Icons.access_time,
                'Total Screen Time',
                '${_report.totalMinutes} minutes',
              ),
              const SizedBox(height: 8),
              _buildSummaryRow(
                Icons.calendar_today,
                'Daily Average',
                '${_report.dailyAverage.toStringAsFixed(1)} minutes',
              ),
              const SizedBox(height: 8),
              _buildSummaryRow(
                Icons.star,
                'Most Watched Day',
                '${_report.mostWatchedDay} (${_report.mostWatchedDayMinutes} min)',
              ),
              const SizedBox(height: 8),
              _buildSummaryRow(
                Icons.warning_amber,
                'Limit Exceeded',
                '${_report.limitExceededDays} days this week',
                isWarning: _report.limitExceededDays > 0,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Weekly chart
        Text(
          'Daily Usage',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: _buildWeeklyChart(weeklyUsage, dailyLimit),
        ),
        
        const SizedBox(height: 24),
        
        // Content categories
        Text(
          'Most Watched Categories',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildCategoriesChart(_report.mostWatchedCategories),
      ],
    );
  }
  
  Widget _buildSummaryRow(IconData icon, String label, String value, {bool isWarning = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isWarning ? Colors.orange : Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            color: isWarning ? Colors.orange : null,
            fontWeight: isWarning ? FontWeight.bold : null,
          ),
        ),
      ],
    );
  }
  
  Widget _buildWeeklyChart(List<UsageDay> weeklyUsage, int dailyLimit) {
    final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        final day = weeklyUsage[index];
        final maxValue = math.max(dailyLimit, day.minutesUsed);
        final percentage = day.minutesUsed / maxValue;
        final overLimit = day.minutesUsed > dailyLimit;
        
        return Expanded(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  alignment: Alignment.bottomCenter,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Limit line
                      Positioned(
                        bottom: (dailyLimit / maxValue) * 150,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          color: Colors.red.withAlpha(153), // ~0.6 opacity
                        ),
                      ),
                      
                      // Bar
                      FractionallySizedBox(
                        heightFactor: percentage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: overLimit 
                                ? Colors.red.withAlpha(179) // ~0.7 opacity
                                : Theme.of(context).primaryColor,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                daysOfWeek[index],
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                '${day.minutesUsed} min',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: overLimit ? FontWeight.bold : null,
                  color: overLimit ? Colors.red : null,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
  
  Widget _buildCategoriesChart(Map<String, int> categories) {
    if (categories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No category data available'),
        ),
      );
    }
    
    // Sort categories by usage time (descending)
    final sortedCategories = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Calculate total minutes
    final totalMinutes = categories.values.fold(0, (sum, value) => sum + value);
    
    return Column(
      children: sortedCategories.map((entry) {
        final category = entry.key;
        final minutes = entry.value;
        final percentage = minutes / totalMinutes;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(category),
                  Text(
                    '$minutes min (${(percentage * 100).toStringAsFixed(1)}%)',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey[200],
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  void _showFullReport(BuildContext context) {
    if (_selectedChildId == null) return;
    
    final selectedChild = widget.children.firstWhere(
      (child) => child.id == _selectedChildId,
    );
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Screen Time Report',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        selectedChild.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Weekly usage section
                        _buildReportSection(
                          'Weekly Usage Summary',
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow('Total Screen Time', '${_report.totalMinutes} minutes'),
                              _buildDetailRow('Daily Average', '${_report.dailyAverage.toStringAsFixed(1)} minutes'),
                              _buildDetailRow('Daily Limit', '${selectedChild.dailyTimeLimit} minutes'),
                              _buildDetailRow('Days Exceeding Limit', '${_report.limitExceededDays} days'),
                              _buildDetailRow('Most Active Day', _report.mostWatchedDay),
                              _buildDetailRow('Least Active Day', _getLeastActiveDay()),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Weekly chart section
                        _buildReportSection(
                          'Daily Usage',
                          SizedBox(
                            height: 250,
                            child: _buildWeeklyChart(_report.weeklyUsage, selectedChild.dailyTimeLimit),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Categories section
                        _buildReportSection(
                          'Content Categories',
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Distribution of viewing time by category'),
                              const SizedBox(height: 16),
                              _buildCategoriesChart(_report.mostWatchedCategories),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Recommendations
                        _buildReportSection(
                          'Recommendations',
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildRecommendation(
                                'Balance Screen Time',
                                'Keep daily usage within the ${selectedChild.dailyTimeLimit}-minute limit. Consider adjusting the limit if it seems too restrictive or lenient.',
                                Icons.balance,
                              ),
                              const SizedBox(height: 16),
                              _buildRecommendation(
                                'Encourage Category Diversity',
                                'Try to balance educational content with entertainment. The "Education" category makes up ${_getCategoryPercentage('Education')}% of total viewing time.',
                                Icons.category,
                              ),
                              const SizedBox(height: 16),
                              _buildRecommendation(
                                'Set Consistent Schedule',
                                'Consistent viewing schedules help establish healthy habits. Consider using the scheduled viewing times feature.',
                                Icons.schedule,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Report saved to downloads folder'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.save_alt),
                    label: const Text('Save as PDF'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Report shared via email'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildReportSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        content,
      ],
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
  
  Widget _buildRecommendation(String title, String description, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withAlpha(26), // ~0.1 opacity
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(description),
            ],
          ),
        ),
      ],
    );
  }
  
  String _getLeastActiveDay() {
    final weeklyUsage = _report.weeklyUsage;
    int minMinutes = weeklyUsage[0].minutesUsed;
    int minIndex = 0;
    final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    for (int i = 1; i < weeklyUsage.length; i++) {
      if (weeklyUsage[i].minutesUsed < minMinutes) {
        minMinutes = weeklyUsage[i].minutesUsed;
        minIndex = i;
      }
    }
    
    return '${daysOfWeek[minIndex]} ($minMinutes min)';
  }
  
  String _getCategoryPercentage(String category) {
    final totalMinutes = _report.mostWatchedCategories.values.fold(0, (sum, value) => sum + value);
    final categoryMinutes = _report.mostWatchedCategories[category] ?? 0;
    
    if (totalMinutes == 0) return '0';
    return (categoryMinutes / totalMinutes * 100).toStringAsFixed(1);
  }
}