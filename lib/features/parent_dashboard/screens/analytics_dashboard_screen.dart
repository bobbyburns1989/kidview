import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kidview/config/themes.dart';
import 'package:kidview/data/models/parent_model.dart';
import 'package:kidview/data/providers/auth_provider.dart';
import 'package:kidview/data/services/usage_tracking_service.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UsageTrackingService _usageService = UsageTrackingService();
  Child? _selectedChild;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final parent = authProvider.parent;
    final children = parent?.children ?? [];
    
    // Initialize tracking service with children data
    if (children.isNotEmpty) {
      _usageService.initializeDemoData(children);
      
      // Set default selected child if none is selected
      _selectedChild ??= children.first;
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        backgroundColor: AppThemes.primaryDark,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Usage', icon: Icon(Icons.bar_chart)),
            Tab(text: 'Content', icon: Icon(Icons.pie_chart)),
            Tab(text: 'Insights', icon: Icon(Icons.lightbulb_outline)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Child selector
          if (children.isNotEmpty) _buildChildSelector(children),
          
          // Content
          Expanded(
            child: _selectedChild != null
                ? TabBarView(
                    controller: _tabController,
                    children: [
                      _buildUsageTab(),
                      _buildContentTab(),
                      _buildInsightsTab(),
                    ],
                  )
                : const Center(
                    child: Text(
                      'No children added yet. Add a child profile to see analytics.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChildSelector(List<Child> children) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.grey[100],
      child: Row(
        children: [
          const Text(
            'Selected Child:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedChild!.id,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(),
              ),
              items: children.map((child) {
                return DropdownMenuItem<String>(
                  value: child.id,
                  child: Text(child.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedChild = children.firstWhere((child) => child.id == value);
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUsageTab() {
    if (_selectedChild == null) {
      return const Center(child: Text('No child selected'));
    }
    
    final weeklyUsage = _usageService.getWeeklyUsage(_selectedChild!.id);
    final todayUsage = _usageService.getTodayUsage(_selectedChild!.id);
    
    // Calculate percentage of daily limit used
    final percentUsed = (todayUsage.minutesUsed / _selectedChild!.dailyTimeLimit) * 100;
    final limitExceeded = todayUsage.minutesUsed > _selectedChild!.dailyTimeLimit;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's usage card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Usage",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${todayUsage.minutesUsed} minutes',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: limitExceeded ? Colors.red : Colors.green,
                              ),
                            ),
                            Text(
                              'of ${_selectedChild!.dailyTimeLimit} minute limit',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: _UsageProgressBar(
                          percentage: percentUsed.clamp(0, 100).toDouble(),
                          isExceeded: limitExceeded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Weekly usage chart
          const Text(
            'Weekly Usage',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: _WeeklyUsageChart(
              weeklyData: weeklyUsage,
              dailyLimit: _selectedChild!.dailyTimeLimit,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Video view history
          const Text(
            'Recently Viewed',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...todayUsage.contentViewed.entries.map((entry) {
            return ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.play_circle_filled, color: Colors.grey),
              ),
              title: Text('Video ${entry.key.replaceAll('video-', '')}'),
              subtitle: Text('${entry.value} minutes'),
              trailing: const Icon(Icons.info_outline),
              onTap: () {
                // View video details
              },
            );
          }),
          
          if (todayUsage.contentViewed.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No videos watched today',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildContentTab() {
    if (_selectedChild == null) {
      return const Center(child: Text('No child selected'));
    }
    
    final categoryDistribution = _usageService.getMostWatchedCategories(_selectedChild!.id);
    final report = _usageService.generateReport(_selectedChild!.id);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content Summary Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.pie_chart, color: Colors.deepPurple, size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        'Content Overview',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  _buildInsightRow(
                    'Total Categories', 
                    '${categoryDistribution.length}',
                    Icons.category,
                  ),
                  _buildInsightRow(
                    'Most Watched', 
                    categoryDistribution.entries.isEmpty 
                        ? 'None' 
                        : categoryDistribution.entries.reduce(
                            (a, b) => a.value > b.value ? a : b
                          ).key.substring(0, 1).toUpperCase() + 
                          categoryDistribution.entries.reduce(
                            (a, b) => a.value > b.value ? a : b
                          ).key.substring(1),
                    Icons.star,
                  ),
                  _buildInsightRow(
                    'Balance Score', 
                    '${_calculateBalanceScore(categoryDistribution).toStringAsFixed(1)}%',
                    Icons.balance,
                    _calculateBalanceScore(categoryDistribution) > 70 ? Colors.green : 
                    _calculateBalanceScore(categoryDistribution) < 40 ? Colors.orange : null,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Content distribution chart
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Content Category Distribution',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _ContentDistributionChart(
                      categoryData: categoryDistribution,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Category breakdown
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Content Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (categoryDistribution.isNotEmpty)
                    ...categoryDistribution.entries.map((entry) {
                      final percentage = categoryDistribution.values.fold(0, (a, b) => a + b) > 0
                          ? (entry.value / categoryDistribution.values.fold(0, (a, b) => a + b)) * 100
                          : 0.0;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getCategoryColor(entry.key),
                                child: Icon(_getCategoryIcon(entry.key), color: Colors.white),
                              ),
                              title: Text(
                                entry.key.substring(0, 1).toUpperCase() + entry.key.substring(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text('${entry.value} minutes watched'),
                              trailing: Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: percentage / 100,
                                      minHeight: 8,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _getCategoryColor(entry.key),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Text(
                                        'Engagement:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildRatingStars(
                                        report.contentEngagementRatings[entry.key] ?? 3.0,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    })
                  else
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No content viewed yet',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Recommended Content
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.recommend, color: Colors.orange, size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        'Recommended Topics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  
                  if (categoryDistribution.isNotEmpty) 
                    ..._generateRecommendedTopics(categoryDistribution).map((topic) {
                      return ListTile(
                        leading: Icon(
                          _getTopicIcon(topic),
                          color: Colors.orange,
                        ),
                        title: Text(topic),
                        subtitle: const Text('Based on viewing patterns'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // View recommended topic content
                        },
                      );
                    })
                  else
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'View more content to get personalized recommendations',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  double _calculateBalanceScore(Map<String, int> categoryDistribution) {
    if (categoryDistribution.isEmpty) return 0;
    if (categoryDistribution.length == 1) return 30; // Single category - low balance
    
    final total = categoryDistribution.values.fold(0, (a, b) => a + b);
    if (total == 0) return 0;
    
    // Calculate standard deviation
    final mean = total / categoryDistribution.length;
    final sumSquaredDiff = categoryDistribution.values.fold(
      0.0, (sum, minutes) => sum + pow(minutes - mean, 2));
    final stdDev = sqrt(sumSquaredDiff / categoryDistribution.length);
    
    // Calculate coefficient of variation (CV) - lower is better balanced
    final cv = stdDev / mean;
    
    // Convert to score (100 = perfectly balanced, 0 = completely unbalanced)
    return (100 * (1 - min(cv, 1))).clamp(0, 100).toDouble();
  }
  
  List<String> _generateRecommendedTopics(Map<String, int> categoryDistribution) {
    final allTopics = {
      'science': ['Astronomy', 'Chemistry Experiments', 'Animal Kingdom'],
      'math': ['Geometry', 'Fun with Numbers', 'Math Puzzles'],
      'language': ['Storytelling', 'Vocabulary Building', 'Reading Adventures'],
      'art': ['Drawing Basics', 'Colorful Creations', 'Art History for Kids'],
      'music': ['Musical Instruments', 'Sing Along', 'Music Theory for Kids'],
      'history': ['Ancient Civilizations', 'Historic Inventions', 'World Explorers'],
    };
    
    // Get topics from most watched categories
    final recommendations = <String>[];
    
    if (categoryDistribution.isNotEmpty) {
      // Get top 2 categories
      final sortedCategories = categoryDistribution.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      for (int i = 0; i < min(2, sortedCategories.length); i++) {
        final category = sortedCategories[i].key;
        final topics = allTopics[category] ?? [];
        if (topics.isNotEmpty) {
          recommendations.add(topics[Random().nextInt(topics.length)]);
        }
      }
      
      // Add one recommendation from a less-watched category for diversity
      final lessWatchedCategories = allTopics.keys
          .where((key) => !categoryDistribution.containsKey(key) || 
              !sortedCategories.take(2).map((e) => e.key).contains(key))
          .toList();
      
      if (lessWatchedCategories.isNotEmpty) {
        final randomCategory = lessWatchedCategories[Random().nextInt(lessWatchedCategories.length)];
        final topics = allTopics[randomCategory] ?? [];
        if (topics.isNotEmpty) {
          recommendations.add(topics[Random().nextInt(topics.length)]);
        }
      }
    }
    
    return recommendations;
  }
  
  IconData _getTopicIcon(String topic) {
    final topicLower = topic.toLowerCase();
    
    if (topicLower.contains('astronomy') || topicLower.contains('planet')) {
      return Icons.public;
    } else if (topicLower.contains('chemistry') || topicLower.contains('experiment')) {
      return Icons.science;
    } else if (topicLower.contains('animal')) {
      return Icons.pets;
    } else if (topicLower.contains('geometry') || topicLower.contains('math')) {
      return Icons.calculate;
    } else if (topicLower.contains('story') || topicLower.contains('reading')) {
      return Icons.menu_book;
    } else if (topicLower.contains('vocabulary')) {
      return Icons.spellcheck;
    } else if (topicLower.contains('drawing') || topicLower.contains('art')) {
      return Icons.brush;
    } else if (topicLower.contains('music')) {
      return Icons.music_note;
    } else if (topicLower.contains('history') || topicLower.contains('ancient')) {
      return Icons.history_edu;
    } else {
      return Icons.stars;
    }
  }
  
  Widget _buildInsightsTab() {
    if (_selectedChild == null) {
      return const Center(child: Text('No child selected'));
    }
    
    final report = _usageService.generateReport(_selectedChild!.id);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Usage Summary Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.analytics, color: Colors.blue, size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        'Usage Summary',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  _buildInsightRow(
                    'Total Screen Time', 
                    '${report.totalMinutes} minutes',
                    Icons.access_time,
                  ),
                  _buildInsightRow(
                    'Daily Average', 
                    '${report.dailyAverage.toStringAsFixed(1)} minutes',
                    Icons.calendar_today,
                  ),
                  _buildInsightRow(
                    'Most Active Day', 
                    '${report.mostWatchedDay} (${report.mostWatchedDayMinutes} min)',
                    Icons.star,
                  ),
                  _buildInsightRow(
                    'Limit Exceeded', 
                    '${report.limitExceededDays} days this week',
                    Icons.warning,
                    report.limitExceededDays > 0 ? Colors.orange : null,
                  ),
                  _buildInsightRow(
                    'Week-over-Week', 
                    '${report.weekOverWeekChange >= 0 ? '+' : ''}${report.weekOverWeekChange.toStringAsFixed(1)}%',
                    Icons.trending_up,
                    report.weekOverWeekChange > 10 ? Colors.orange : 
                    report.weekOverWeekChange < 0 ? Colors.green : null,
                  ),
                  _buildInsightRow(
                    'Consistency Score', 
                    '${report.consistencyScore.toStringAsFixed(1)}%',
                    Icons.check_circle,
                    report.consistencyScore > 80 ? Colors.green : 
                    report.consistencyScore < 60 ? Colors.orange : null,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Learning Patterns Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.psychology, color: Colors.purple, size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        'Learning Patterns',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  _buildInsightRow(
                    'Attention Span', 
                    '${report.attentionSpan.toStringAsFixed(1)} minutes',
                    Icons.timer,
                  ),
                  _buildInsightRow(
                    'Best Time of Day', 
                    report.bestTimeOfDay,
                    Icons.access_time,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Detected Learning Styles',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: report.learningPatterns.map((pattern) {
                      return Chip(
                        backgroundColor: Colors.purple.withAlpha(51), // ~0.2 opacity
                        label: Text(pattern),
                        avatar: const Icon(Icons.school, size: 16),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Content Engagement',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...report.contentEngagementRatings.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Text(
                            entry.key.substring(0, 1).toUpperCase() + entry.key.substring(1),
                            style: const TextStyle(fontSize: 14),
                          ),
                          const Spacer(),
                          _buildRatingStars(entry.value),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Recommendations Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb, color: Colors.amber, size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        'Recommendations',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  _buildRecommendationCard(
                    'Screen Time',
                    report.dailyAverage > _selectedChild!.dailyTimeLimit * 0.9
                        ? 'Your child is consistently approaching or exceeding their daily screen time limit. Consider adjusting the limit or implementing more structured viewing times.'
                        : 'Your child is maintaining healthy screen time habits, staying within the set limits most days.',
                    report.dailyAverage > _selectedChild!.dailyTimeLimit * 0.9
                        ? Colors.orange
                        : Colors.green,
                  ),
                  
                  const SizedBox(height: 12),
                  _buildRecommendationCard(
                    'Content Diversity',
                    report.mostWatchedCategories.length < 3
                        ? 'Your child is focusing on a limited number of content categories. Consider introducing more diverse educational content to broaden their interests.'
                        : 'Your child is exploring a diverse range of content categories, which is great for learning and development.',
                    report.mostWatchedCategories.length < 3
                        ? Colors.blue
                        : Colors.green,
                  ),
                  
                  const SizedBox(height: 12),
                  _buildRecommendationCard(
                    'Viewing Pattern',
                    report.mostWatchedDayMinutes > _selectedChild!.dailyTimeLimit * 1.5
                        ? 'There\'s a significant spike in usage on ${report.mostWatchedDay}. Consider more consistent viewing schedules throughout the week.'
                        : 'Your child has relatively consistent viewing patterns across the week, which is a healthy habit.',
                    report.mostWatchedDayMinutes > _selectedChild!.dailyTimeLimit * 1.5
                        ? Colors.orange
                        : Colors.green,
                  ),
                  
                  const SizedBox(height: 12),
                  _buildRecommendationCard(
                    'Optimal Learning',
                    'Based on your child\'s patterns, we recommend scheduling educational content in the ${report.bestTimeOfDay.toLowerCase()} on ${report.bestDayRecommendation}s for optimal learning and engagement.',
                    Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRatingStars(double rating) {
    int fullStars = rating.floor();
    bool hasHalfStar = rating - fullStars >= 0.5;
    int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(
          fullStars, 
          (_) => const Icon(Icons.star, color: Colors.amber, size: 18)
        ),
        if (hasHalfStar)
          const Icon(Icons.star_half, color: Colors.amber, size: 18),
        ...List.generate(
          emptyStars, 
          (_) => const Icon(Icons.star_border, color: Colors.amber, size: 18)
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
  
  Widget _buildInsightRow(String title, String value, IconData icon, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.blue[800], size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecommendationCard(String title, String recommendation, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(26), // ~0.1 opacity
        border: Border.all(color: color.withAlpha(77)), // ~0.3 opacity
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            recommendation,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'science':
        return Colors.blue;
      case 'math':
        return Colors.green;
      case 'language':
        return Colors.purple;
      case 'art':
        return Colors.orange;
      case 'music':
        return Colors.pink;
      case 'history':
        return Colors.brown;
      default:
        return Colors.blueGrey;
    }
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'science':
        return Icons.science;
      case 'math':
        return Icons.calculate;
      case 'language':
        return Icons.book;
      case 'art':
        return Icons.brush;
      case 'music':
        return Icons.music_note;
      case 'history':
        return Icons.history_edu;
      default:
        return Icons.category;
    }
  }
}

class _UsageProgressBar extends StatelessWidget {
  final double percentage;
  final bool isExceeded;
  
  const _UsageProgressBar({
    required this.percentage,
    required this.isExceeded,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isExceeded ? Colors.red : Colors.green,
              ),
            ),
            if (isExceeded)
              const Text(
                'LIMIT EXCEEDED',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Container(
                width: (percentage / 100) * MediaQuery.of(context).size.width * 0.35,
                decoration: BoxDecoration(
                  color: isExceeded ? Colors.red : Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeeklyUsageChart extends StatelessWidget {
  final List<UsageDay> weeklyData;
  final int dailyLimit;
  
  const _WeeklyUsageChart({
    required this.weeklyData,
    required this.dailyLimit,
  });
  
  @override
  Widget build(BuildContext context) {
    // Find max value for scaling
    final maxValue = weeklyData.fold(
      0, 
      (max, day) => day.minutesUsed > max ? day.minutesUsed : max,
    );
    
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return Column(
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(weeklyData.length, (index) {
              final day = weeklyData[index];
              final dayName = dayNames[index];
              final barHeight = day.minutesUsed / (maxValue > 0 ? maxValue : 1);
              final exceededLimit = day.minutesUsed > dailyLimit;
              
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${day.minutesUsed}',
                    style: TextStyle(
                      fontSize: 10,
                      color: exceededLimit ? Colors.red : Colors.grey[700],
                      fontWeight: exceededLimit ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 28,
                    height: barHeight * 150,
                    decoration: BoxDecoration(
                      color: exceededLimit ? Colors.red : AppThemes.primaryDark.withAlpha(179), // ~0.7 opacity
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dayName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        // Daily limit indicator
        Row(
          children: [
            Container(
              width: 16,
              height: 4,
              color: Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              'Daily Limit: $dailyLimit minutes',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ContentDistributionChart extends StatelessWidget {
  final Map<String, int> categoryData;
  
  const _ContentDistributionChart({
    required this.categoryData,
  });
  
  @override
  Widget build(BuildContext context) {
    if (categoryData.isEmpty) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      );
    }
    
    // Total minutes for calculating percentages
    final totalMinutes = categoryData.values.fold(0, (sum, minutes) => sum + minutes);
    
    // Create color mapping
    final colorMap = <String, Color>{};
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.brown,
      Colors.teal,
      Colors.indigo,
    ];
    
    int colorIndex = 0;
    for (final category in categoryData.keys) {
      colorMap[category] = colors[colorIndex % colors.length];
      colorIndex++;
    }
    
    return Row(
      children: [
        // Pie chart
        Expanded(
          flex: 2,
          child: CustomPaint(
            painter: _PieChartPainter(
              categoryData: categoryData,
              colorMap: colorMap,
              totalValue: totalMinutes,
            ),
            child: const SizedBox(
              height: 200,
              width: 200,
            ),
          ),
        ),
        
        // Legend
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: categoryData.entries.map((entry) {
                final percentage = (entry.value / totalMinutes) * 100;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: colorMap[entry.key],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.key.substring(0, 1).toUpperCase() + entry.key.substring(1),
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final Map<String, int> categoryData;
  final Map<String, Color> colorMap;
  final int totalValue;
  
  _PieChartPainter({
    required this.categoryData,
    required this.colorMap,
    required this.totalValue,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width < size.height ? size.width / 2 : size.height / 2;
    
    double startAngle = 0;
    
    categoryData.forEach((category, value) {
      final sweepAngle = (value / totalValue) * 2 * 3.14159;
      final paint = Paint()
        ..color = colorMap[category] ?? Colors.grey
        ..style = PaintingStyle.fill;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      startAngle += sweepAngle;
    });
    
    // Draw center circle (optional)
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      center,
      radius * 0.5,
      centerPaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}