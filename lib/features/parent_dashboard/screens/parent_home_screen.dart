import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:kidview/data/providers/auth_provider.dart';
import 'package:kidview/data/models/parent_model.dart';
import 'package:kidview/core/constants/route_constants.dart';
import 'package:kidview/shared/widgets/error_view.dart';
// import 'package:kidview/features/parent_dashboard/widgets/child_profile_dialogs.dart';
import 'package:kidview/features/parent_dashboard/widgets/welcome_card.dart';
import 'package:kidview/features/parent_dashboard/widgets/child_profile_card.dart';
import 'package:kidview/features/parent_dashboard/widgets/quick_access_card.dart';
import 'package:kidview/features/parent_dashboard/widgets/child_profile_creator.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      // In a real app, load additional data here
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return ErrorView(
        error: _error!,
        onRetry: _loadData,
      );
    }

    final authProvider = Provider.of<AuthProvider>(context);
    final parent = authProvider.parent;

    if (parent == null) {
      return Center(
        child: Text(
          'No parent data available. Please sign in again.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome card
          WelcomeCard(
            parent: parent, 
            onAddChild: () => _showEnhancedChildProfileCreator(context),
          ),
          const SizedBox(height: 24),
          
          // Child profiles
          if (parent.children.isNotEmpty) ...[
            _buildChildProfilesGrid(parent.children),
            const SizedBox(height: 24),
          ],
          
          // Quick access section
          Text(
            'Quick Access',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickAccessGrid(),
        ],
      ),
    );
  }

  Widget _buildChildProfilesGrid(List<Child> children) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) {
        final child = children[index];
        return ChildProfileCard(child: child);
      },
    );
  }

  Widget _buildQuickAccessGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: QuickAccessCard(
                icon: Icons.shield,
                title: 'Parental Controls',
                onTap: () => _navigateToParentalControls(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: QuickAccessCard(
                icon: Icons.history,
                title: 'View History',
                onTap: () => _navigateToViewHistory(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: QuickAccessCard(
                icon: Icons.content_paste_search,
                title: 'Content Filters',
                onTap: () => _navigateToContentFilters(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: QuickAccessCard(
                icon: Icons.settings,
                title: 'Settings',
                onTap: () => _navigateToSettings(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: QuickAccessCard(
                icon: Icons.analytics,
                title: 'Analytics',
                onTap: () => _navigateToAnalytics(context),
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(child: SizedBox()), // Empty space for balance
          ],
        ),
      ],
    );
  }

  void _signOut(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();
    if (mounted) {
      context.go(Routes.login);
    }
  }

  void _navigateToParentalControls(BuildContext context) {
    context.go(Routes.parentControls);
  }

  void _navigateToViewHistory(BuildContext context) {
    context.go(Routes.parentHistory);
  }

  void _navigateToContentFilters(BuildContext context) {
    context.go(Routes.parentContentFilters);
  }

  void _navigateToSettings(BuildContext context) {
    context.go(Routes.parentSettings);
  }
  
  void _navigateToAnalytics(BuildContext context) {
    context.go(Routes.parentAnalytics);
  }
  
  // Show enhanced child profile creator
  void _showEnhancedChildProfileCreator(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => ChildProfileCreator(
          onCreateChild: (child) {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            authProvider.addChild(child);
          },
        ),
      ),
    );
  }
}