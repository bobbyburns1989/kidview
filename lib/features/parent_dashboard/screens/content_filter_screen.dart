import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:kidview/core/constants/route_constants.dart';
import 'package:kidview/data/models/parent_model.dart';
import 'package:kidview/data/providers/auth_provider.dart';
import 'package:kidview/features/parent_dashboard/widgets/child_selector.dart';
import 'package:kidview/features/parent_dashboard/widgets/child_content_settings.dart';

class ContentFilterScreen extends StatefulWidget {
  const ContentFilterScreen({super.key});

  @override
  State<ContentFilterScreen> createState() => _ContentFilterScreenState();
}

class _ContentFilterScreenState extends State<ContentFilterScreen> {
  Child? _selectedChild;
  bool _isLoading = false;
  String? _error;
  List<String> _updatedCategories = [];
  List<String> _updatedInterests = [];
  Map<String, int> _updatedDistribution = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final parent = Provider.of<AuthProvider>(context, listen: false).parent;
    if (parent != null && parent.children.isNotEmpty) {
      _selectChild(parent.children.first);
    }
  }

  void _selectChild(Child child) {
    setState(() {
      _selectedChild = child;
      _updatedCategories = List<String>.from(child.allowedContentCategories);
      _updatedInterests = List<String>.from(child.specialInterests);
      _updatedDistribution = Map<String, int>.from(child.contentDistribution);
    });
  }

  Future<void> _saveChanges() async {
    if (_selectedChild == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final updatedChild = Child(
        id: _selectedChild!.id,
        name: _selectedChild!.name,
        avatarUrl: _selectedChild!.avatarUrl,
        ageGroup: _selectedChild!.ageGroup,
        allowedContentCategories: _updatedCategories,
        dailyTimeLimit: _selectedChild!.dailyTimeLimit,
        watchHistory: _selectedChild!.watchHistory,
        favorites: _selectedChild!.favorites,
        specialInterests: _updatedInterests,
        contentDistribution: _updatedDistribution,
        contentTags: _selectedChild!.contentTags,
      );

      await authProvider.updateChild(updatedChild);
      
      setState(() {
        _selectedChild = updatedChild;
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Content settings updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating settings: $_error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateCategories(List<String> categories) {
    setState(() {
      _updatedCategories = categories;
    });
  }

  void _updateInterests(List<String> interests) {
    setState(() {
      _updatedInterests = interests;
    });
  }

  void _updateDistribution(String category, int value) {
    setState(() {
      _updatedDistribution[category] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final parent = Provider.of<AuthProvider>(context).parent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Filters'),
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
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _selectedChild != null ? _saveChanges : null,
              tooltip: 'Save Changes',
            ),
        ],
      ),
      body: parent == null
          ? const Center(child: Text('No parent data available'))
          : parent.children.isEmpty
              ? const Center(child: Text('No children profiles found'))
              : _buildContent(parent),
    );
  }

  Widget _buildContent(Parent parent) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Child selector
          ChildSelector(
            children: parent.children,
            selectedChild: _selectedChild,
            onChildSelected: _selectChild,
          ),
          
          const SizedBox(height: 24),
          
          if (_selectedChild != null) ...[
            // Child-specific content settings
            ChildContentSettings(
              child: _selectedChild!,
              allowedCategories: _updatedCategories,
              specialInterests: _updatedInterests,
              contentDistribution: _updatedDistribution,
              onCategoriesChanged: _updateCategories,
              onInterestsChanged: _updateInterests,
              onDistributionChanged: _updateDistribution,
            ),
          ] else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('Please select a child to customize content settings'),
              ),
            ),
        ],
      ),
    );
  }
}