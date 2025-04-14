import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kidview/data/models/parent_model.dart' as model;
import 'package:kidview/data/services/firebase_service.dart';
import 'package:kidview/data/services/analytics_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AuthProvider extends ChangeNotifier {
  // User state
  String? _userId;
  model.Parent? _parent;
  bool _isLoading = false;
  String? _error;
  bool _isEmailVerified = false;

  // Services
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();
  final AnalyticsService _analyticsService = AnalyticsService();
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Getters
  String? get userId => _userId;
  model.Parent? get parent => _parent;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _userId != null;
  bool get isEmailVerified => _isEmailVerified;
  User? get currentUser => _auth.currentUser;

  AuthProvider() {
    // Check if user is already logged in
    _initializeAuthState();
  }

  // Initialize auth state from Firebase
  Future<void> _initializeAuthState() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      _userId = currentUser.uid;
      _isEmailVerified = currentUser.emailVerified;
      
      // Get parent profile from Firestore
      try {
        final parent = await _firebaseService.getParentProfile(_userId!);
        if (parent != null) {
          _parent = parent;
        }
      } catch (e) {
        print('Error fetching parent profile: $e');
      }
      
      notifyListeners();
    }
  }

  // Authentication methods
  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Sign in with Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        _userId = userCredential.user!.uid;
        _isEmailVerified = userCredential.user!.emailVerified;
        
        // Get parent profile from Firestore
        final parent = await _firebaseService.getParentProfile(_userId!);
        if (parent != null) {
          _parent = parent;
        }
        
        // Log successful login to analytics
        await _analyticsService.logLogin(method: 'email');
        
        // Set user properties for analytics
        await _analyticsService.setUserProperties(
          userId: _userId!,
          isParent: true,
        );
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      // If we get here, authentication failed
      _isLoading = false;
      _error = 'Unable to sign in';
      notifyListeners();
      return false;
      
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      
      // Map Firebase Auth error codes to user-friendly messages
      switch (e.code) {
        case 'user-not-found':
          _error = 'No user found with this email';
          break;
        case 'wrong-password':
          _error = 'Incorrect password';
          break;
        case 'invalid-credential':
          _error = 'Invalid email or password';
          break;
        case 'user-disabled':
          _error = 'This account has been disabled';
          break;
        case 'too-many-requests':
          _error = 'Too many failed login attempts. Try again later';
          break;
        default:
          _error = 'Authentication failed: ${e.message}';
      }
      
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String displayName) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Create user with Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        // Set display name
        await userCredential.user!.updateDisplayName(displayName);
        
        _userId = userCredential.user!.uid;
        _isEmailVerified = false;
        
        // Create a new parent profile
        final newParent = model.Parent(
          id: _userId!,
          email: email,
          displayName: displayName,
          children: [], // Start with no children
          controls: model.ParentalControls(
            pinProtected: true,
            pin: '1234', // Default PIN
            allowDownloads: true,
            preventAppSwitching: false,
            scheduledViewingTimes: [],
            contentFilters: {
              'violence': true,
              'language': true,
              'fear': true,
              'consumerism': true,
            },
          ),
        );
        
        // Save parent to Firestore
        await _firebaseService.createParentProfile(newParent);
        
        _parent = newParent;
        
        // Send email verification
        await sendEmailVerification();
        
        // Log successful registration to analytics
        await _analyticsService.logSignUp(method: 'email');
        
        // Set user properties for analytics
        await _analyticsService.setUserProperties(
          userId: _userId!,
          isParent: true,
        );
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      // If we get here, registration failed
      _isLoading = false;
      _error = 'Unable to create account';
      notifyListeners();
      return false;
      
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      
      // Map Firebase Auth error codes to user-friendly messages
      switch (e.code) {
        case 'email-already-in-use':
          _error = 'An account already exists with this email';
          break;
        case 'invalid-email':
          _error = 'The email address is not valid';
          break;
        case 'weak-password':
          _error = 'Password is too weak';
          break;
        case 'operation-not-allowed':
          _error = 'Account creation is disabled';
          break;
        default:
          _error = 'Registration failed: ${e.message}';
      }
      
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      print('Error sending verification email: $e');
    }
  }
  
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _auth.sendPasswordResetEmail(email: email);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      
      switch (e.code) {
        case 'user-not-found':
          _error = 'No user found with this email';
          break;
        case 'invalid-email':
          _error = 'The email address is not valid';
          break;
        default:
          _error = 'Password reset failed: ${e.message}';
      }
      
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> checkEmailVerified() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      
      // Reload user to get the latest verification status
      await user.reload();
      _isEmailVerified = user.emailVerified;
      notifyListeners();
      
      return _isEmailVerified;
    } catch (e) {
      print('Error checking email verification: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Log event before signing out
      if (_userId != null) {
        await _analytics.logEvent(
          name: 'logout',
          parameters: {'user_id': _userId!},
        );
      }
      
      await _auth.signOut();
      
      _userId = null;
      _parent = null;
      _isEmailVerified = false;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Error signing out: ${e.toString()}';
      notifyListeners();
    }
  }

  // Parent profile management methods
  Future<bool> updateParent(model.Parent updatedParent) async {
    if (_userId == null) return false;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      _parent = updatedParent;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Child profile management methods
  Future<bool> addChild(model.Child child) async {
    if (_parent == null) return false;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 600));
      
      final updatedChildren = [..._parent!.children, child];
      _parent = _updateParentChildren(updatedChildren);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> updateChild(model.Child updatedChild) async {
    if (_parent == null) return false;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // Update child profile in database
      // In a real app, this would update Firestore
      
      final updatedChildren = _parent!.children.map((child) {
        if (child.id == updatedChild.id) {
          return updatedChild;
        }
        return child;
      }).toList();
      
      _parent = _updateParentChildren(updatedChildren);
      
      // Log child profile update to analytics
      await _analyticsService.logChildProfileUpdate(
        childId: updatedChild.id,
        updateType: 'profile_update',
        parentId: _userId!,
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Parental control management methods
  Future<bool> updateControls(model.ParentalControls updatedControls) async {
    if (_parent == null) return false;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // Save updated controls to Firestore
      // In a real app, this would be implemented to update the database
      
      // Log parental control changes to analytics
      await _analyticsService.logParentalControlChange(
        childId: 'all', // Global controls for all children
        controlType: 'global_controls',
        changeDescription: 'Updated parental controls',
      );
      
      _parent = _updateParentControls(updatedControls);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Helper methods
  model.Parent _updateParentChildren(List<model.Child> children) {
    return model.Parent(
      id: _parent!.id,
      email: _parent!.email,
      displayName: _parent!.displayName,
      children: children,
      controls: _parent!.controls,
    );
  }
  
  model.Parent _updateParentControls(model.ParentalControls controls) {
    return model.Parent(
      id: _parent!.id,
      email: _parent!.email,
      displayName: _parent!.displayName,
      children: _parent!.children,
      controls: controls,
    );
  }
  
  // Clear any error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}