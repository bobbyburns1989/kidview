import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kidview/data/models/parent_model.dart';

class PinManagement extends StatefulWidget {
  final ParentalControls controls;
  final Function(bool) onTogglePinProtection;
  final Function(String) onPinChanged;
  
  const PinManagement({
    super.key,
    required this.controls,
    required this.onTogglePinProtection,
    required this.onPinChanged,
  });

  @override
  State<PinManagement> createState() => _PinManagementState();
}

class _PinManagementState extends State<PinManagement> {
  late bool _isPinProtectionEnabled;
  final TextEditingController _currentPinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  bool _isChangingPin = false;
  bool _obscureCurrentPin = true;
  bool _obscureNewPin = true;
  bool _obscureConfirmPin = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _isPinProtectionEnabled = widget.controls.pinProtected;
  }
  
  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _togglePinProtection(bool value) {
    // If enabling PIN protection, we need to set up a new PIN if one doesn't exist
    if (value && widget.controls.pin.isEmpty) {
      _startChangingPin();
      return;
    }
    
    setState(() {
      _isPinProtectionEnabled = value;
    });
    widget.onTogglePinProtection(value);
  }
  
  void _startChangingPin() {
    setState(() {
      _isChangingPin = true;
      _error = null;
      
      // Clear controllers
      _currentPinController.clear();
      _newPinController.clear();
      _confirmPinController.clear();
    });
  }
  
  void _cancelChangingPin() {
    setState(() {
      _isChangingPin = false;
      _error = null;
    });
  }
  
  void _submitPinChange() {
    // Validate current PIN
    if (widget.controls.pin.isNotEmpty && 
        _currentPinController.text != widget.controls.pin) {
      setState(() {
        _error = 'Current PIN is incorrect';
      });
      return;
    }
    
    // Validate new PIN
    if (_newPinController.text.length != 4 || 
        !RegExp(r'^\d{4}$').hasMatch(_newPinController.text)) {
      setState(() {
        _error = 'PIN must be exactly 4 digits';
      });
      return;
    }
    
    // Validate PIN confirmation
    if (_newPinController.text != _confirmPinController.text) {
      setState(() {
        _error = 'New PINs do not match';
      });
      return;
    }
    
    // Submit the PIN change
    widget.onPinChanged(_newPinController.text);
    
    // Enable PIN protection if it's not already enabled
    if (!_isPinProtectionEnabled) {
      setState(() {
        _isPinProtectionEnabled = true;
      });
      widget.onTogglePinProtection(true);
    }
    
    // Close the PIN change form
    setState(() {
      _isChangingPin = false;
      _error = null;
    });
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PIN updated successfully'),
        backgroundColor: Colors.green,
      ),
    );
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
              'PIN Management',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (!_isChangingPin) _buildPinSettings(context),
            if (_isChangingPin) _buildPinChangeForm(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPinSettings(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('PIN Protection'),
          subtitle: const Text('Require a PIN to access parental controls'),
          value: _isPinProtectionEnabled,
          onChanged: _togglePinProtection,
          secondary: Icon(
            Icons.security,
            color: _isPinProtectionEnabled 
                ? Theme.of(context).primaryColor 
                : Colors.grey,
          ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.pin),
          title: const Text('Change PIN'),
          subtitle: widget.controls.pin.isEmpty 
              ? const Text('No PIN set yet') 
              : const Text('Update your security PIN'),
          trailing: const Icon(Icons.chevron_right),
          enabled: _isPinProtectionEnabled,
          onTap: _isPinProtectionEnabled ? _startChangingPin : null,
        ),
        const SizedBox(height: 8),
        
        // Security tips
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Security Tips:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('• Use a PIN that\'s easy for you to remember but hard for children to guess'),
              Text('• Avoid using birthdays or simple patterns like 1234'),
              Text('• Change your PIN periodically for better security'),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildPinChangeForm(BuildContext context) {
    final bool isNewPin = widget.controls.pin.isEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isNewPin ? 'Set PIN' : 'Change PIN',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        // Current PIN input (only if not setting a new PIN)
        if (!isNewPin) ...[
          TextFormField(
            controller: _currentPinController,
            decoration: InputDecoration(
              labelText: 'Current PIN',
              hintText: '4-digit PIN',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscureCurrentPin ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _obscureCurrentPin = !_obscureCurrentPin;
                  });
                },
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            obscureText: _obscureCurrentPin,
            maxLength: 4,
          ),
          const SizedBox(height: 8),
        ],
        
        // New PIN input
        TextFormField(
          controller: _newPinController,
          decoration: InputDecoration(
            labelText: 'New PIN',
            hintText: '4-digit PIN',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(_obscureNewPin ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _obscureNewPin = !_obscureNewPin;
                });
              },
            ),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          obscureText: _obscureNewPin,
          maxLength: 4,
        ),
        const SizedBox(height: 8),
        
        // Confirm PIN input
        TextFormField(
          controller: _confirmPinController,
          decoration: InputDecoration(
            labelText: 'Confirm New PIN',
            hintText: '4-digit PIN',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirmPin ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _obscureConfirmPin = !_obscureConfirmPin;
                });
              },
            ),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          obscureText: _obscureConfirmPin,
          maxLength: 4,
        ),
        
        // Error message
        if (_error != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
        
        const SizedBox(height: 16),
        
        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _cancelChangingPin,
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _submitPinChange,
              child: const Text('Save PIN'),
            ),
          ],
        ),
      ],
    );
  }
}