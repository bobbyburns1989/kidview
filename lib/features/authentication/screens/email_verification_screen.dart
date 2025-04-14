import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:kidview/data/providers/auth_provider.dart';
import 'package:kidview/core/constants/route_constants.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isLoading = false;
  String? _error;
  Timer? _timer;
  int _timeLeft = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startVerificationCheck() {
    // Check every 5 seconds if the email has been verified
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      _checkEmailVerification();
    });
    
    // Start countdown for resend button
    _startResendTimer();
  }
  
  void _startResendTimer() {
    setState(() {
      _timeLeft = 60;
      _canResend = false;
    });
    
    // Create a timer that counts down from 60 seconds
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  Future<void> _checkEmailVerification() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isVerified = await authProvider.checkEmailVerified();
    
    if (isVerified && mounted) {
      _timer?.cancel();
      context.go(Routes.parentHome);
    }
  }

  Future<void> _resendVerificationEmail() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      await authProvider.sendEmailVerification();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent. Please check your inbox.'),
          ),
        );
        
        _startResendTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  void _goToLogin() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.signOut();
    context.go(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.email_outlined,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              Text(
                'Verify Your Email',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'We\'ve sent a verification email to:',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? 'your email address',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text(
                'Please check your inbox and click the verification link to continue.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'If you don\'t see the email, check your spam folder.',
                textAlign: TextAlign.center,
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _checkEmailVerification,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('I\'ve Verified My Email'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: (_canResend && !_isLoading) 
                    ? _resendVerificationEmail 
                    : null,
                child: Text(
                  _canResend 
                      ? 'Resend Verification Email' 
                      : 'Resend Email in $_timeLeft seconds',
                ),
              ),
              TextButton(
                onPressed: _goToLogin,
                child: const Text('Back to Login'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red.shade800),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}