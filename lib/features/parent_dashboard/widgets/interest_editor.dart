import 'package:flutter/material.dart';

class InterestEditor extends StatefulWidget {
  final List<String> interests;
  final Function(List<String>) onChange;

  const InterestEditor({
    super.key,
    required this.interests,
    required this.onChange,
  });

  @override
  State<InterestEditor> createState() => _InterestEditorState();
}

class _InterestEditorState extends State<InterestEditor> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addInterest() {
    final newInterest = _controller.text.trim();
    
    if (newInterest.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an interest';
      });
      return;
    }
    
    if (widget.interests.contains(newInterest)) {
      setState(() {
        _errorMessage = 'This interest is already added';
      });
      return;
    }
    
    // Add the new interest
    widget.onChange([...widget.interests, newInterest]);
    
    // Clear the input field and error message
    _controller.clear();
    setState(() {
      _errorMessage = null;
    });
  }

  void _removeInterest(String interest) {
    widget.onChange(widget.interests.where((i) => i != interest).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Interest input field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Add Interest',
                      hintText: 'e.g. Dinosaurs, Space, Robots',
                      errorText: _errorMessage,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addInterest(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: _addInterest,
                  color: Theme.of(context).primaryColor,
                  tooltip: 'Add Interest',
                ),
              ],
            ),
            
            // Display current interests as chips
            if (widget.interests.isNotEmpty) ...[              
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.interests.map((interest) {
                  return Chip(
                    label: Text(interest),
                    deleteIcon: const Icon(Icons.cancel, size: 16),
                    onDeleted: () => _removeInterest(interest),
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                  );
                }).toList(),
              ),
            ] else
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text('No special interests added yet'),
              ),
          ],
        ),
      ),
    );
  }
}