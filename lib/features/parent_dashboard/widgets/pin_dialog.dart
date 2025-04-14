import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinDialog extends StatefulWidget {
  const PinDialog({super.key});

  @override
  State<PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<PinDialog> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    final pin = _pinController.text;
    final confirmPin = _confirmPinController.text;
    
    // Validate PIN format (must be 4 digits)
    if (pin.length != 4 || !RegExp(r'^[0-9]{4}$').hasMatch(pin)) {
      setState(() {
        _errorMessage = 'PIN must be 4 digits';
      });
      return;
    }
    
    // Validate PINs match
    if (pin != confirmPin) {
      setState(() {
        _errorMessage = 'PINs do not match';
      });
      return;
    }
    
    // All validations passed, return the PIN
    Navigator.of(context).pop(pin);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Security PIN'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Create a 4-digit PIN to protect child mode. You will need this PIN to exit child mode.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pinController,
              decoration: const InputDecoration(
                labelText: 'Enter PIN',
                border: OutlineInputBorder(),
                hintText: '4-digit PIN',
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
              inputFormatters: [
                LengthLimitingTextInputFormatter(4),
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPinController,
              decoration: const InputDecoration(
                labelText: 'Confirm PIN',
                border: OutlineInputBorder(),
                hintText: 'Re-enter PIN',
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
              inputFormatters: [
                LengthLimitingTextInputFormatter(4),
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            if (_errorMessage != null) ...[              
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _validateAndSubmit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}