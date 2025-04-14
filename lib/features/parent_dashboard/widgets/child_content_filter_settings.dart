import 'package:flutter/material.dart';
import 'package:kidview/data/models/parent_model.dart';

class ChildContentFilterSettings extends StatefulWidget {
  final Child child;
  final Map<String, bool> globalFilters;
  final Function(Child) onChildUpdated;

  const ChildContentFilterSettings({
    super.key,
    required this.child,
    required this.globalFilters,
    required this.onChildUpdated,
  });

  @override
  State<ChildContentFilterSettings> createState() => _ChildContentFilterSettingsState();
}

class _ChildContentFilterSettingsState extends State<ChildContentFilterSettings> {
  late Map<String, bool> _childFilters;
  bool _useGlobalFilters = true;
  bool _isAdvancedMode = false;
  
  // Store the global filter state mapping to child's content tags
  final Map<String, List<String>> _filterToTagsMap = {
    'violence': ['Violence', 'Conflict', 'Action'],
    'language': ['Language', 'Adult Themes'],
    'fear': ['Scary', 'Intense Scenes', 'Suspense'],
    'consumerism': ['Commercial Content', 'Product Placement', 'Advertising'],
  };

  @override
  void initState() {
    super.initState();
    
    // Initialize with child's content tags if they exist
    final contentTags = widget.child.contentTags;
    
    if (contentTags.isEmpty) {
      // Use global filters if no specific filters set
      _childFilters = Map.from(widget.globalFilters);
      _useGlobalFilters = true;
    } else {
      // Child has custom filters
      _childFilters = {};
      _useGlobalFilters = false;
      
      // Map content tags back to filter categories
      for (final entry in _filterToTagsMap.entries) {
        final filterKey = entry.key;
        final filterTags = entry.value;
        
        // Check if any of the filter's tags are present in the child's tags
        bool filterActive = false;
        for (final tags in contentTags.values) {
          for (final tag in tags) {
            if (filterTags.contains(tag)) {
              filterActive = true;
              break;
            }
          }
          if (filterActive) break;
        }
        
        _childFilters[filterKey] = filterActive;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildUseGlobalSwitch(),
          const SizedBox(height: 16),
          
          // Content filter controls
          if (!_useGlobalFilters) _buildContentFilterControls(),
          
          const SizedBox(height: 24),
          _buildAdvancedModeToggle(),
          
          // Advanced content tagging
          if (_isAdvancedMode && !_useGlobalFilters) 
            _buildAdvancedContentTagging(),
          
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Content Filters for ${widget.child.name}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Customize content filtering based on ${widget.child.name}\'s needs',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }
  
  Widget _buildUseGlobalSwitch() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Use Global Filter Settings'),
              subtitle: const Text('Apply the same filters to all children'),
              value: _useGlobalFilters,
              onChanged: (value) {
                setState(() {
                  _useGlobalFilters = value;
                  if (value) {
                    // Reset to global filters
                    _childFilters = Map.from(widget.globalFilters);
                  }
                });
              },
            ),
            if (_useGlobalFilters)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(top: 8),
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
                    Expanded(
                      child: Text(
                        '${widget.child.name} is using the global filter settings. To customize, turn off this option.',
                        style: const TextStyle(fontSize: 14),
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
  
  Widget _buildContentFilterControls() {
    // Create a map of filter names to user-friendly display names
    final filterLabels = {
      'violence': 'Block violent content',
      'language': 'Block strong language',
      'fear': 'Block scary content',
      'consumerism': 'Block commercial/advertising content',
    };
    
    // Count active filters
    final int activeFilterCount = _childFilters.values.where((isActive) => isActive).length;
    final int totalFilters = _childFilters.length;
    
    String protectionLevel = 'Low';
    Color protectionColor = Colors.orange;
    
    if (activeFilterCount > totalFilters * 0.7) {
      protectionLevel = 'High';
      protectionColor = Colors.green;
    } else if (activeFilterCount > totalFilters * 0.3) {
      protectionLevel = 'Medium';
      protectionColor = Colors.amber;
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Custom Content Filters',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Protection level indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: protectionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: protectionColor.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.security, color: protectionColor, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '$protectionLevel Protection',
                    style: TextStyle(
                      color: protectionColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Content filter switches
            ...filterLabels.entries.map((entry) {
              final filterKey = entry.key;
              final filterLabel = entry.value;
              
              return SwitchListTile(
                title: Text(filterLabel),
                subtitle: Text(_getFilterDescription(filterKey)),
                value: _childFilters[filterKey] ?? false,
                onChanged: (bool value) {
                  setState(() {
                    _childFilters[filterKey] = value;
                  });
                },
                secondary: Icon(
                  _getFilterIcon(filterKey),
                  color: _childFilters[filterKey] ?? false
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAdvancedModeToggle() {
    return SwitchListTile(
      title: const Text('Advanced Content Filtering'),
      subtitle: const Text('Fine-tune filtering with detailed content tags'),
      value: _isAdvancedMode,
      onChanged: _useGlobalFilters ? null : (value) {
        setState(() {
          _isAdvancedMode = value;
        });
      },
    );
  }
  
  Widget _buildAdvancedContentTagging() {
    // Create categories of tags that parents can select
    final tagCategories = {
      'Values': [
        'Kindness', 'Empathy', 'Sharing', 'Honesty', 'Perseverance', 
        'Teamwork', 'Leadership', 'Conflict resolution', 'Diversity', 'Inclusion'
      ],
      'Content Format': [
        'Animation', 'Live-action', 'Puppetry', 'Interactive', 
        'Short-form', 'Long-form'
      ],
      'Excluded Themes': [
        'Violence', 'Conflict', 'Adult Themes', 'Scary', 'Intense Scenes', 
        'Language', 'Commercial Content', 'Product Placement', 'Advertising'
      ],
    };
    
    // Initialize selected tags using the child's current content tags
    final selectedTags = Map<String, List<String>>.from(widget.child.contentTags);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advanced Content Tagging',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select specific content themes to allow or exclude',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            
            // Tag selection for each category
            ...tagCategories.entries.map((entry) {
              final category = entry.key;
              final tags = entry.value;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags.map((tag) {
                      final isSelected = selectedTags[category]?.contains(tag) ?? false;
                      
                      return FilterChip(
                        label: Text(tag),
                        selected: isSelected,
                        selectedColor: category == 'Excluded Themes'
                            ? Colors.red.withOpacity(0.2)
                            : Theme.of(context).primaryColor.withOpacity(0.2),
                        checkmarkColor: category == 'Excluded Themes'
                            ? Colors.red
                            : Theme.of(context).primaryColor,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              // Add tag
                              if (!selectedTags.containsKey(category)) {
                                selectedTags[category] = [];
                              }
                              selectedTags[category]!.add(tag);
                              
                              // Update filter settings based on excluded themes
                              if (category == 'Excluded Themes') {
                                _updateFilterFromTag(tag, true);
                              }
                            } else {
                              // Remove tag
                              selectedTags[category]?.remove(tag);
                              if (selectedTags[category]?.isEmpty ?? false) {
                                selectedTags.remove(category);
                              }
                              
                              // Update filter settings based on excluded themes
                              if (category == 'Excluded Themes') {
                                _updateFilterFromTag(tag, false);
                              }
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
  
  void _updateFilterFromTag(String tag, bool value) {
    // Map tags back to filter categories
    for (final entry in _filterToTagsMap.entries) {
      final filterKey = entry.key;
      final filterTags = entry.value;
      
      if (filterTags.contains(tag)) {
        _childFilters[filterKey] = value;
        break;
      }
    }
  }
  
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _saveChanges,
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
  
  void _saveChanges() {
    final updatedChild = Child(
      id: widget.child.id,
      name: widget.child.name,
      avatarUrl: widget.child.avatarUrl,
      ageGroup: widget.child.ageGroup,
      allowedContentCategories: widget.child.allowedContentCategories,
      dailyTimeLimit: widget.child.dailyTimeLimit,
      watchHistory: widget.child.watchHistory,
      favorites: widget.child.favorites,
      specialInterests: widget.child.specialInterests,
      contentDistribution: widget.child.contentDistribution,
      // Update content tags
      contentTags: _useGlobalFilters ? {} : _getUpdatedContentTags(),
    );
    
    widget.onChildUpdated(updatedChild);
    Navigator.of(context).pop();
  }
  
  Map<String, List<String>> _getUpdatedContentTags() {
    if (_isAdvancedMode) {
      // Use the tags directly from the advanced mode
      final contentTags = Map<String, List<String>>.from(widget.child.contentTags);
      
      // Ensure 'Excluded Themes' category is updated based on filter settings
      for (final entry in _filterToTagsMap.entries) {
        final filterKey = entry.key;
        final filterActive = _childFilters[filterKey] ?? false;
        final tags = entry.value;
        
        if (filterActive) {
          // Add excluded themes when filter is active
          if (!contentTags.containsKey('Excluded Themes')) {
            contentTags['Excluded Themes'] = [];
          }
          
          for (final tag in tags) {
            if (!contentTags['Excluded Themes']!.contains(tag)) {
              contentTags['Excluded Themes']!.add(tag);
            }
          }
        } else {
          // Remove excluded themes when filter is inactive
          contentTags['Excluded Themes']?.removeWhere((tag) => tags.contains(tag));
          if (contentTags['Excluded Themes']?.isEmpty ?? false) {
            contentTags.remove('Excluded Themes');
          }
        }
      }
      
      return contentTags;
    } else {
      // Create simple content tags based on filter settings
      final Map<String, List<String>> contentTags = {};
      
      for (final entry in _filterToTagsMap.entries) {
        final filterKey = entry.key;
        final filterActive = _childFilters[filterKey] ?? false;
        
        if (filterActive) {
          if (!contentTags.containsKey('Excluded Themes')) {
            contentTags['Excluded Themes'] = [];
          }
          
          // Add all tags for this filter
          for (final tag in entry.value) {
            if (!contentTags['Excluded Themes']!.contains(tag)) {
              contentTags['Excluded Themes']!.add(tag);
            }
          }
        }
      }
      
      return contentTags;
    }
  }
  
  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'violence':
        return Icons.dangerous;
      case 'language':
        return Icons.chat_bubble;
      case 'fear':
        return Icons.mood_bad;
      case 'consumerism':
        return Icons.shopping_cart;
      default:
        return Icons.filter_list;
    }
  }
  
  String _getFilterDescription(String filter) {
    switch (filter) {
      case 'violence':
        return 'Filters out intense action, fighting scenes, and conflict';
      case 'language':
        return 'Filters out strong language and inappropriate discussions';
      case 'fear':
        return 'Filters out scary or suspenseful content that may cause anxiety';
      case 'consumerism':
        return 'Filters out excessive advertising and commercial content';
      default:
        return 'Blocks inappropriate content';
    }
  }
}