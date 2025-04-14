import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:kidview/data/providers/auth_provider.dart';
import 'package:kidview/core/constants/route_constants.dart';
import 'package:kidview/features/authentication/widgets/register_form.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const SizedBox(height: 32),
                
                // Registration form
                RegisterForm(
                  isLoading: authProvider.isLoading,
                  onRegister: _register,
                ),
                
                // Error message
                if (authProvider.error != null) ...[
                  const SizedBox(height: 16),
                  _buildErrorMessage(context, authProvider.error!),
                ],
                
                // Login link
                const SizedBox(height: 24),
                _buildLoginLink(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          'Join KidView',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Create an account to provide your children with safe and educational content',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildErrorMessage(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Text(
        error,
        style: TextStyle(color: Colors.red.shade800),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Already have an account?'),
        TextButton(
          onPressed: () => context.go(Routes.login),
          child: const Text('Log In'),
        ),
      ],
    );
  }

  Future<void> _register(String name, String email, String password) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.register(
      email.trim(),
      password,
      name.trim(),
    );
    
    if (success && mounted) {
      // Direct user to verification screen
      context.go(Routes.emailVerification);
    }
  }
}