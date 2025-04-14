import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:kidview/data/models/parent_model.dart';
import 'package:kidview/data/providers/auth_provider.dart';
import 'package:kidview/data/providers/theme_provider.dart';
import 'package:kidview/core/constants/route_constants.dart';
import 'package:kidview/features/parent_dashboard/widgets/child_profile_dialogs_helpers.dart';
import 'package:kidview/features/parent_dashboard/widgets/child_detail_tabs.dart';

class ChildProfileDialogs {
  // Helpers delegated to the ChildProfileDialogHelpers class
  static Widget buildTabButton(BuildContext context, String label, bool isSelected, VoidCallback onTap) =>
    ChildProfileDialogHelpers.buildTabButton(context, label, isSelected, onTap);
  
  static Widget infoRow(String label, String value) =>
    ChildProfileDialogHelpers.infoRow(label, value);
  
  // Show dialog with child details
  static void showChildDetailsDialog(BuildContext context, Child child) {
    int currentTab = 0;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(child.name, style: TextStyle(fontWeight: FontWeight.bold)),
            content: Container(
              width: double.maxFinite,
              constraints: BoxConstraints(maxHeight: 450),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tab selection
                  SizedBox(
                    height: 50,
                    child: Row(
                      children: [
                        buildTabButton(
                          context, 
                          'Basic Info', 
                          currentTab == 0, 
                          () => setState(() => currentTab = 0)
                        ),
                        buildTabButton(
                          context, 
                          'Content', 
                          currentTab == 1, 
                          () => setState(() => currentTab = 1)
                        ),
                        buildTabButton(
                          context, 
                          'Filters', 
                          currentTab == 2, 
                          () => setState(() => currentTab = 2)
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  SizedBox(height: 8),
                  
                  // Tab content
                  Expanded(
                    child: SingleChildScrollView(
                      child: [
                        // Basic Info tab
                        ChildDetailTabs.buildBasicInfoTab(child, context),
                        
                        // Content tab
                        ChildDetailTabs.buildContentTab(child, context),
                        
                        // Filters tab
                        ChildDetailTabs.buildFiltersTab(child, context),
                      ][currentTab],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  showEnterChildModeDialog(context, child);
                },
                child: Text('Enter Kid Mode'),
              ),
            ],
          );
        }
      ),
    );
  }
  
  // Show dialog to add a new child profile
  static void showAddChildDialog(BuildContext context) {
    final nameController = TextEditingController();
    String selectedAgeGroup = 'younger';
    final formKey = GlobalKey<FormState>();
    
    // Content categories
    List<String> allCategories = [
      'Education', 'Science', 'Math', 'Music', 
      'Art', 'Language', 'Fun', 'Technology'
    ];
    
    // Selected categories (starts with some default ones)
    List<String> selectedCategories = ['Education', 'Fun'];
    
    // Special interests predefined list
    List<String> allSpecialInterests = [
      'Animals', 'Dinosaurs', 'Space', 'Robots', 'Cooking', 
      'Trains', 'Cars', 'Planes', 'Music', 'Sports',
      'Insects', 'Plants', 'Oceans', 'Building', 'Drawing',
      'Coding', 'Chemistry', 'Geography', 'History', 'Mythology'
    ];
    
    // Selected special interests
    List<String> selectedSpecialInterests = [];
    
    // Content distribution percentages
    Map<String, int> contentDistribution = {
      'Values & Social Skills': 30,
      'STEM Topics': 25,
      'Creative Arts': 20,
      'Special Interests': 15,
      'Free Choice': 10,
    };
    
    // Multi-dimensional tagging
    Map<String, List<String>> allContentTags = {
      'Values': [
        'Kindness', 'Empathy', 'Sharing', 'Honesty', 'Perseverance', 
        'Teamwork', 'Leadership', 'Conflict resolution', 'Diversity', 'Inclusion'
      ],
      'Learning Approach': [
        'Instructional', 'Exploratory', 'Problem-solving', 'Project-based', 
        'Gamified learning'
      ],
      'Content Format': [
        'Animation', 'Live-action', 'Puppetry', 'Interactive', 
        'Short-form', 'Long-form'
      ],
      'Developmental Focus': [
        'Fine motor skills', 'Gross motor skills', 'Vocabulary building', 
        'Mathematical thinking', 'Scientific reasoning', 'Emotional intelligence', 
        'Social skills', 'Logical reasoning'
      ],
    };
    
    // Selected tags per category
    Map<String, List<String>> selectedContentTags = {
      'Values': ['Kindness', 'Sharing'],
      'Learning Approach': ['Exploratory'],
      'Content Format': ['Animation', 'Short-form'],
      'Developmental Focus': ['Vocabulary building'],
    };
    
    // Daily time limit in minutes (default: 60 minutes)
    int timeLimit = 60;
    
    // Current tab index
    int currentTabIndex = 0;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Child Profile',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Container(
                width: double.maxFinite,
                constraints: BoxConstraints(maxHeight: 500),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tab selection
                      SizedBox(
                        height: 50,
                        child: Row(
                          children: [
                            ChildProfileDialogs.buildTabButton(
                              context, 
                              'Basic Info', 
                              currentTabIndex == 0, 
                              () => setState(() => currentTabIndex = 0)
                            ),
                            ChildProfileDialogs.buildTabButton(
                              context, 
                              'Content Preferences', 
                              currentTabIndex == 1, 
                              () => setState(() => currentTabIndex = 1)
                            ),
                            ChildProfileDialogs.buildTabButton(
                              context, 
                              'Advanced Filters', 
                              currentTabIndex == 2, 
                              () => setState(() => currentTabIndex = 2)
                            ),
                          ],
                        ),
                      ),
                      Divider(),
                      SizedBox(height: 8),
                      
                      // Content based on selected tab
                      Expanded(
                        child: SingleChildScrollView(
                          child: [
                            // Basic Info Tab
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name field
                                TextFormField(
                                  controller: nameController,
                                  decoration: InputDecoration(
                                    labelText: 'Child Name',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.person),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a name';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),
                                
                                // Age group selection
                                Text('Age Group:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Row(
                                  children: [
                                    Expanded(
                                      child: RadioListTile<String>(
                                        title: Text('4-7 years'),
                                        value: 'younger',
                                        groupValue: selectedAgeGroup,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedAgeGroup = value!;
                                          });
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: RadioListTile<String>(
                                        title: Text('8-12 years'),
                                        value: 'older',
                                        groupValue: selectedAgeGroup,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedAgeGroup = value!;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                
                                // Time limit slider
                                Text('Daily Time Limit: $timeLimit minutes', 
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                                Slider(
                                  value: timeLimit.toDouble(),
                                  min: 15,
                                  max: 180,
                                  divisions: 11,
                                  label: "$timeLimit min",
                                  onChanged: (value) {
                                    setState(() {
                                      timeLimit = value.round();
                                    });
                                  },
                                ),
                                SizedBox(height: 16),
                                
                                // Content categories
                                Text('Allowed Content Categories:', 
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: allCategories.map((category) {
                                    final isSelected = selectedCategories.contains(category);
                                    return FilterChip(
                                      label: Text(category),
                                      selected: isSelected,
                                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                      checkmarkColor: Theme.of(context).primaryColor,
                                      onSelected: (selected) {
                                        setState(() {
                                          if (selected) {
                                            selectedCategories.add(category);
                                          } else {
                                            selectedCategories.remove(category);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                            
                            // Content Preferences Tab
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Special interests section
                                Text('Special Interests:', 
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('Select topics your child is particularly interested in',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                SizedBox(height: 8),
                                
                                // Search box for special interests
                                TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search interests...',
                                    prefixIcon: Icon(Icons.search),
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    // Filter interests based on search (not implemented in this demo)
                                  },
                                ),
                                SizedBox(height: 12),
                                
                                // Special interests chips
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: allSpecialInterests.map((interest) {
                                    final isSelected = selectedSpecialInterests.contains(interest);
                                    return FilterChip(
                                      label: Text(interest),
                                      selected: isSelected,
                                      selectedColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                                      checkmarkColor: Theme.of(context).colorScheme.secondary,
                                      onSelected: (selected) {
                                        setState(() {
                                          if (selected) {
                                            selectedSpecialInterests.add(interest);
                                          } else {
                                            selectedSpecialInterests.remove(interest);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                                SizedBox(height: 24),
                                
                                // Content distribution
                                Text('Content Distribution:', 
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('Adjust how content is balanced across different areas',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                SizedBox(height: 16),
                                
                                // Content distribution sliders
                                ...contentDistribution.entries.map((entry) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(entry.key),
                                          Text('${entry.value}%'),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      // Visual representation of percentage
                                      Container(
                                        width: double.infinity,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: entry.value / 100,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Theme.of(context).primaryColor,
                                                  Theme.of(context).colorScheme.secondary,
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Slider(
                                        value: entry.value.toDouble(),
                                        min: 0,
                                        max: 100,
                                        divisions: 20,
                                        onChanged: (value) {
                                          setState(() {
                                            // Update this category's percentage
                                            contentDistribution[entry.key] = value.round();
                                            
                                            // Calculate total of all percentages
                                            int total = contentDistribution.values.fold(0, (sum, value) => sum + value);
                                            
                                            // If total exceeds 100%, adjust other categories proportionally
                                            if (total > 100) {
                                              // Calculate how much we need to reduce other categories
                                              int excess = total - 100;
                                              int otherCategoriesTotal = total - entry.value;
                                              
                                              // Adjust other categories proportionally
                                              for (var key in contentDistribution.keys) {
                                                if (key != entry.key && otherCategoriesTotal > 0) {
                                                  // Calculate reduction proportionally
                                                  double reduction = excess * (contentDistribution[key]! / otherCategoriesTotal);
                                                  contentDistribution[key] = (contentDistribution[key]! - reduction.round()).clamp(0, 100);
                                                }
                                              }
                                            }
                                          });
                                        },
                                      ),
                                      SizedBox(height: 8),
                                    ],
                                  );
                                }),
                              ],
                            ),
                            
                            // Advanced Filters Tab
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Multi-dimensional Tagging System:', 
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('Fine-tune content selection with specific tags',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                SizedBox(height: 16),
                                
                                // Multi-dimensional tagging system
                                ...allContentTags.entries.map((entry) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(entry.key, style: TextStyle(fontWeight: FontWeight.bold)),
                                      SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: entry.value.map((tag) {
                                          final isSelected = selectedContentTags[entry.key]?.contains(tag) ?? false;
                                          return FilterChip(
                                            label: Text(tag),
                                            selected: isSelected,
                                            selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                            checkmarkColor: Theme.of(context).primaryColor,
                                            onSelected: (selected) {
                                              setState(() {
                                                if (selected) {
                                                  selectedContentTags.putIfAbsent(entry.key, () => []);
                                                  selectedContentTags[entry.key]!.add(tag);
                                                } else {
                                                  selectedContentTags[entry.key]?.remove(tag);
                                                  // Remove the key if the list is empty
                                                  if (selectedContentTags[entry.key]?.isEmpty ?? false) {
                                                    selectedContentTags.remove(entry.key);
                                                  }
                                                }
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                                      SizedBox(height: 16),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ][currentTabIndex],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      if (selectedCategories.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please select at least one content category')),
                        );
                        return;
                      }
                      
                      // Create the child model
                      final newChild = Child(
                        id: 'child-${DateTime.now().millisecondsSinceEpoch}',
                        name: nameController.text.trim(),
                        avatarUrl: '',
                        ageGroup: selectedAgeGroup,
                        allowedContentCategories: selectedCategories,
                        dailyTimeLimit: timeLimit,
                        watchHistory: [],
                        favorites: [],
                        specialInterests: selectedSpecialInterests,
                        contentDistribution: contentDistribution,
                        contentTags: selectedContentTags,
                      );
                      
                      // Add child to parent
                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      authProvider.addChild(newChild);
                      
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Add Child'),
                ),
              ],
            );
          }
        );
      },
    );
  }
  
  // Show dialog to edit an existing child profile
  static void showEditChildDialog(BuildContext context, Child child) {
    final nameController = TextEditingController(text: child.name);
    String selectedAgeGroup = child.ageGroup;
    final formKey = GlobalKey<FormState>();
    
    // Content categories
    List<String> allCategories = [
      'Education', 'Science', 'Math', 'Music', 
      'Art', 'Language', 'Fun', 'Technology'
    ];
    
    // Selected categories (initialize with child's current categories)
    List<String> selectedCategories = List.from(child.allowedContentCategories);
    
    // Special interests predefined list
    List<String> allSpecialInterests = [
      'Animals', 'Dinosaurs', 'Space', 'Robots', 'Cooking', 
      'Trains', 'Cars', 'Planes', 'Music', 'Sports',
      'Insects', 'Plants', 'Oceans', 'Building', 'Drawing',
      'Coding', 'Chemistry', 'Geography', 'History', 'Mythology'
    ];
    
    // Selected special interests
    List<String> selectedSpecialInterests = List.from(child.specialInterests);
    
    // Content distribution percentages
    Map<String, int> contentDistribution = Map.from(child.contentDistribution);
    if (contentDistribution.isEmpty) {
      contentDistribution = {
        'Values & Social Skills': 30,
        'STEM Topics': 25,
        'Creative Arts': 20,
        'Special Interests': 15,
        'Free Choice': 10,
      };
    }
    
    // Multi-dimensional tagging
    Map<String, List<String>> allContentTags = {
      'Values': [
        'Kindness', 'Empathy', 'Sharing', 'Honesty', 'Perseverance', 
        'Teamwork', 'Leadership', 'Conflict resolution', 'Diversity', 'Inclusion'
      ],
      'Learning Approach': [
        'Instructional', 'Exploratory', 'Problem-solving', 'Project-based', 
        'Gamified learning'
      ],
      'Content Format': [
        'Animation', 'Live-action', 'Puppetry', 'Interactive', 
        'Short-form', 'Long-form'
      ],
      'Developmental Focus': [
        'Fine motor skills', 'Gross motor skills', 'Vocabulary building', 
        'Mathematical thinking', 'Scientific reasoning', 'Emotional intelligence', 
        'Social skills', 'Logical reasoning'
      ],
    };
    
    // Selected tags per category
    Map<String, List<String>> selectedContentTags = Map.from(child.contentTags);
    if (selectedContentTags.isEmpty) {
      selectedContentTags = {
        'Values': ['Kindness', 'Sharing'],
        'Learning Approach': ['Exploratory'],
        'Content Format': ['Animation', 'Short-form'],
        'Developmental Focus': ['Vocabulary building'],
      };
    }
    
    // Daily time limit in minutes
    int timeLimit = child.dailyTimeLimit;
    
    // Current tab index
    int currentTabIndex = 0;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit ${child.name}\'s Profile',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Container(
                width: double.maxFinite,
                constraints: BoxConstraints(maxHeight: 500),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tab selection
                      SizedBox(
                        height: 50,
                        child: Row(
                          children: [
                            ChildProfileDialogs.buildTabButton(
                              context, 
                              'Basic Info', 
                              currentTabIndex == 0, 
                              () => setState(() => currentTabIndex = 0)
                            ),
                            ChildProfileDialogs.buildTabButton(
                              context, 
                              'Content Preferences', 
                              currentTabIndex == 1, 
                              () => setState(() => currentTabIndex = 1)
                            ),
                            ChildProfileDialogs.buildTabButton(
                              context, 
                              'Advanced Filters', 
                              currentTabIndex == 2, 
                              () => setState(() => currentTabIndex = 2)
                            ),
                          ],
                        ),
                      ),
                      Divider(),
                      SizedBox(height: 8),
                      
                      // Content based on selected tab
                      Expanded(
                        child: SingleChildScrollView(
                          child: [
                            // Basic Info Tab
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name field
                                TextFormField(
                                  controller: nameController,
                                  decoration: InputDecoration(
                                    labelText: 'Child Name',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.person),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a name';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),
                                
                                // Age group selection
                                Text('Age Group:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Row(
                                  children: [
                                    Expanded(
                                      child: RadioListTile<String>(
                                        title: Text('4-7 years'),
                                        value: 'younger',
                                        groupValue: selectedAgeGroup,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedAgeGroup = value!;
                                          });
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: RadioListTile<String>(
                                        title: Text('8-12 years'),
                                        value: 'older',
                                        groupValue: selectedAgeGroup,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedAgeGroup = value!;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                
                                // Time limit slider
                                Text('Daily Time Limit: $timeLimit minutes', 
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                                Slider(
                                  value: timeLimit.toDouble(),
                                  min: 15,
                                  max: 180,
                                  divisions: 11,
                                  label: "$timeLimit min",
                                  onChanged: (value) {
                                    setState(() {
                                      timeLimit = value.round();
                                    });
                                  },
                                ),
                                SizedBox(height: 16),
                                
                                // Content categories
                                Text('Allowed Content Categories:', 
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: allCategories.map((category) {
                                    final isSelected = selectedCategories.contains(category);
                                    return FilterChip(
                                      label: Text(category),
                                      selected: isSelected,
                                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                      checkmarkColor: Theme.of(context).primaryColor,
                                      onSelected: (selected) {
                                        setState(() {
                                          if (selected) {
                                            selectedCategories.add(category);
                                          } else {
                                            selectedCategories.remove(category);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                            
                            // Content Preferences Tab
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Special interests section
                                Text('Special Interests:', 
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('Select topics your child is particularly interested in',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                SizedBox(height: 8),
                                
                                // Search box for special interests
                                TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search interests...',
                                    prefixIcon: Icon(Icons.search),
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    // Filter interests based on search (not implemented in this demo)
                                  },
                                ),
                                SizedBox(height: 12),
                                
                                // Special interests chips
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: allSpecialInterests.map((interest) {
                                    final isSelected = selectedSpecialInterests.contains(interest);
                                    return FilterChip(
                                      label: Text(interest),
                                      selected: isSelected,
                                      selectedColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                                      checkmarkColor: Theme.of(context).colorScheme.secondary,
                                      onSelected: (selected) {
                                        setState(() {
                                          if (selected) {
                                            selectedSpecialInterests.add(interest);
                                          } else {
                                            selectedSpecialInterests.remove(interest);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                                SizedBox(height: 24),
                                
                                // Content distribution
                                Text('Content Distribution:', 
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('Adjust how content is balanced across different areas',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                SizedBox(height: 16),
                                
                                // Content distribution sliders
                                ...contentDistribution.entries.map((entry) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(entry.key),
                                          Text('${entry.value}%'),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      // Visual representation of percentage
                                      Container(
                                        width: double.infinity,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: entry.value / 100,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Theme.of(context).primaryColor,
                                                  Theme.of(context).colorScheme.secondary,
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Slider(
                                        value: entry.value.toDouble(),
                                        min: 0,
                                        max: 100,
                                        divisions: 20,
                                        onChanged: (value) {
                                          setState(() {
                                            // Update this category's percentage
                                            contentDistribution[entry.key] = value.round();
                                            
                                            // Calculate total of all percentages
                                            int total = contentDistribution.values.fold(0, (sum, value) => sum + value);
                                            
                                            // If total exceeds 100%, adjust other categories proportionally
                                            if (total > 100) {
                                              // Calculate how much we need to reduce other categories
                                              int excess = total - 100;
                                              int otherCategoriesTotal = total - entry.value;
                                              
                                              // Adjust other categories proportionally
                                              for (var key in contentDistribution.keys) {
                                                if (key != entry.key && otherCategoriesTotal > 0) {
                                                  // Calculate reduction proportionally
                                                  double reduction = excess * (contentDistribution[key]! / otherCategoriesTotal);
                                                  contentDistribution[key] = (contentDistribution[key]! - reduction.round()).clamp(0, 100);
                                                }
                                              }
                                            }
                                          });
                                        },
                                      ),
                                      SizedBox(height: 8),
                                    ],
                                  );
                                }),
                              ],
                            ),
                            
                            // Advanced Filters Tab
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Multi-dimensional Tagging System:', 
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('Fine-tune content selection with specific tags',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                SizedBox(height: 16),
                                
                                // Multi-dimensional tagging system
                                ...allContentTags.entries.map((entry) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(entry.key, style: TextStyle(fontWeight: FontWeight.bold)),
                                      SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: entry.value.map((tag) {
                                          final isSelected = selectedContentTags[entry.key]?.contains(tag) ?? false;
                                          return FilterChip(
                                            label: Text(tag),
                                            selected: isSelected,
                                            selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                            checkmarkColor: Theme.of(context).primaryColor,
                                            onSelected: (selected) {
                                              setState(() {
                                                if (selected) {
                                                  selectedContentTags.putIfAbsent(entry.key, () => []);
                                                  selectedContentTags[entry.key]!.add(tag);
                                                } else {
                                                  selectedContentTags[entry.key]?.remove(tag);
                                                  // Remove the key if the list is empty
                                                  if (selectedContentTags[entry.key]?.isEmpty ?? false) {
                                                    selectedContentTags.remove(entry.key);
                                                  }
                                                }
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                                      SizedBox(height: 16),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ][currentTabIndex],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      if (selectedCategories.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please select at least one content category')),
                        );
                        return;
                      }
                      
                      // Create the updated child model (keep the same ID and watch history)
                      final updatedChild = Child(
                        id: child.id,
                        name: nameController.text.trim(),
                        avatarUrl: child.avatarUrl,
                        ageGroup: selectedAgeGroup,
                        allowedContentCategories: selectedCategories,
                        dailyTimeLimit: timeLimit,
                        watchHistory: child.watchHistory,
                        favorites: child.favorites,
                        specialInterests: selectedSpecialInterests,
                        contentDistribution: contentDistribution,
                        contentTags: selectedContentTags,
                      );
                      
                      // Update child
                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      authProvider.updateChild(updatedChild);
                      
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Save Changes'),
                ),
              ],
            );
          }
        );
      },
    );
  }
  
  // Show PIN verification dialog to enter child mode
  static void showEnterChildModeDialog(BuildContext context, Child child) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Enter PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please enter your parental PIN to continue'),
            SizedBox(height: 16),
            // PIN entry field would go here
            TextField(
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                hintText: 'PIN',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              
              // In a real app, verify the PIN first
              final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
              if (child.ageGroup == 'younger') {
                themeProvider.setYoungerChildView(true);
              } else {
                themeProvider.setOlderChildView(true);
              }
              
              // Navigate to child home screen
              context.go('${Routes.childHome}?ageGroup=${child.ageGroup}');
            },
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }
}