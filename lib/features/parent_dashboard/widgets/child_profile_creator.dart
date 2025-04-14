import 'package:flutter/material.dart';
import 'package:kidview/data/models/parent_model.dart';
import 'package:kidview/features/parent_dashboard/widgets/profile_creation_steps.dart';
import 'package:kidview/features/parent_dashboard/widgets/child_profile_dialogs_helpers.dart';

class ChildProfileCreator extends StatefulWidget {
  final Function(Child) onCreateChild;
  
  const ChildProfileCreator({
    super.key,
    required this.onCreateChild,
  });

  @override
  State<ChildProfileCreator> createState() => _ChildProfileCreatorState();
}

class _ChildProfileCreatorState extends State<ChildProfileCreator> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _currentStep = 0;
  
  // Child profile data
  String _selectedAgeGroup = 'younger';
  int _timeLimit = 60; // in minutes
  final List<String> _selectedCategories = ['Education', 'Fun'];
  final List<String> _selectedInterests = [];
  
  // Advanced settings
  Map<String, int> _contentDistribution = {
    'Values & Social Skills': 30,
    'STEM Topics': 25,
    'Creative Arts': 20,
    'Special Interests': 15,
    'Free Choice': 10,
  };
  
  final Map<String, List<String>> _selectedContentTags = {
    'Values': ['Kindness', 'Sharing'],
    'Learning Approach': ['Exploratory'],
    'Content Format': ['Animation', 'Short-form'],
    'Developmental Focus': ['Vocabulary building'],
  };
  
  // Avatar selection
  String _avatarColor = 'blue';
  String _avatarEmoji = '😊';
  
  // Content categories
  final List<String> _allCategories = [
    'Education', 'Science', 'Math', 'Music', 
    'Art', 'Language', 'Fun', 'Technology'
  ];
  
  // Special interests
  final List<String> _allInterests = [
    'Animals', 'Dinosaurs', 'Space', 'Robots', 'Cooking', 
    'Trains', 'Cars', 'Planes', 'Music', 'Sports',
    'Insects', 'Plants', 'Oceans', 'Building', 'Drawing',
    'Coding', 'Chemistry', 'Geography', 'History', 'Mythology'
  ];
  
  // Multi-dimensional tagging
  final Map<String, List<String>> _allContentTags = {
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
  
  // Avatar options
  final List<String> _avatarColors = [
    'blue', 'green', 'purple', 'red', 'orange', 'pink'
  ];
  
  final List<String> _avatarEmojis = [
    '😊', '😎', '🤓', '🦄', '🐱', '🐶', '🦁', '🦊', '🐰', '🐼'
  ];
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Child Profile'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_currentStep > 0)
            TextButton.icon(
              onPressed: _goToPreviousStep,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepContinue: _handleContinue,
          onStepCancel: _currentStep > 0 ? _goToPreviousStep : null,
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      _currentStep < 3 ? 'Continue' : 'Create Profile',
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Back'),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Basics'),
              content: _buildBasicInfoStep(),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('Appearance'),
              content: _buildAppearanceStep(),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('Content'),
              content: _buildContentPreferencesStep(),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('Advanced'),
              content: _buildAdvancedSettingsStep(),
              isActive: _currentStep >= 3,
              state: _currentStep == 4 ? StepState.complete : StepState.indexed,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBasicInfoStep() {
    return ProfileCreationSteps.buildBasicInfoStep(
      context: context,
      nameController: _nameController,
      selectedAgeGroup: _selectedAgeGroup,
      timeLimit: _timeLimit,
      onAgeGroupChanged: (value) {
        setState(() {
          _selectedAgeGroup = value;
        });
      },
      onTimeLimitChanged: (value) {
        setState(() {
          _timeLimit = value;
        });
      },
    );
  }
  
  Widget _buildAppearanceStep() {
    return ProfileCreationSteps.buildAppearanceStep(
      context: context,
      name: _nameController.text,
      ageGroup: _selectedAgeGroup,
      avatarColor: _avatarColor,
      avatarEmoji: _avatarEmoji,
      colorOptions: _avatarColors,
      emojiOptions: _avatarEmojis,
      onColorSelected: (color) {
        setState(() {
          _avatarColor = color;
        });
      },
      onEmojiSelected: (emoji) {
        setState(() {
          _avatarEmoji = emoji;
        });
      },
    );
  }
  
  Widget _buildContentPreferencesStep() {
    return ProfileCreationSteps.buildContentPreferencesStep(
      context: context,
      allCategories: _allCategories,
      selectedCategories: _selectedCategories, 
      allInterests: _allInterests,
      selectedInterests: _selectedInterests,
      onCategorySelected: (category, selected) {
        setState(() {
          if (selected) {
            _selectedCategories.add(category);
          } else {
            _selectedCategories.remove(category);
          }
        });
      },
      onInterestSelected: (interest, selected) {
        setState(() {
          if (selected) {
            _selectedInterests.add(interest);
          } else {
            _selectedInterests.remove(interest);
          }
        });
      },
    );
  }
  
  Widget _buildAdvancedSettingsStep() {
    return ProfileCreationSteps.buildAdvancedSettingsStep(
      context: context,
      contentDistribution: _contentDistribution,
      allContentTags: _allContentTags,
      selectedContentTags: _selectedContentTags,
      onDistributionChanged: (key, value) {
        setState(() {
          _contentDistribution = ChildProfileDialogHelpers.adjustContentDistribution(
            _contentDistribution,
            key,
            value,
          );
        });
      },
      onTagSelected: (category, tag, selected) {
        setState(() {
          if (selected) {
            _selectedContentTags.putIfAbsent(category, () => []);
            _selectedContentTags[category]!.add(tag);
          } else {
            _selectedContentTags[category]?.remove(tag);
            // Remove the key if the list is empty
            if (_selectedContentTags[category]?.isEmpty ?? false) {
              _selectedContentTags.remove(category);
            }
          }
        });
      },
      name: _nameController.text,
      ageGroup: _selectedAgeGroup,
      timeLimit: _timeLimit,
      selectedCategories: _selectedCategories,
      selectedInterests: _selectedInterests,
    );
  }
  
  void _handleContinue() {
    if (_currentStep == 0) {
      // Validate basic info step
      if (_formKey.currentState!.validate()) {
        setState(() {
          _currentStep = 1;
        });
      }
    } else if (_currentStep == 3) {
      // Create child profile
      _createChildProfile();
    } else {
      // Continue to next step
      setState(() {
        _currentStep += 1;
      });
    }
  }
  
  void _goToPreviousStep() {
    setState(() {
      _currentStep = _currentStep > 0 ? _currentStep - 1 : 0;
    });
  }
  
  void _createChildProfile() {
    // Generate a unique ID
    final id = 'child-${DateTime.now().millisecondsSinceEpoch}';
    
    // Create avatar URL (would be a real URL in a production app)
    final avatarUrl = '';
    
    // Create the child model
    final newChild = Child(
      id: id,
      name: _nameController.text.trim(),
      avatarUrl: avatarUrl,
      ageGroup: _selectedAgeGroup,
      allowedContentCategories: _selectedCategories,
      dailyTimeLimit: _timeLimit,
      watchHistory: [],
      favorites: [],
      specialInterests: _selectedInterests,
      contentDistribution: _contentDistribution,
      contentTags: _selectedContentTags,
    );
    
    // Call the create child callback
    widget.onCreateChild(newChild);
    
    // Close the dialog
    Navigator.of(context).pop();
  }
}