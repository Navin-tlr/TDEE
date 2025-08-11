import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // This stream will notify the app of any changes in the user's authentication state.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Signs in a user with the provided email and password.
  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // It's good practice to provide user-friendly error messages.
      print('Sign in failed: ${e.message}');
    }
  }

  /// Creates a new user account with the provided email and password.
  /// The backend data initialization is now handled automatically by the
  /// onUserCreate Cloud Function, making this client-side code simpler and more robust.
  Future<void> createUserWithEmail(String email, String password) async {
    try {
      print('AuthService: Attempting to create user in Firebase Auth...');
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      // The explicit HTTP call to the Go backend has been removed.
      // The onUserCreate Cloud Function will now handle the backend initialization automatically.
      print('AuthService: User created successfully. The Cloud Function will now initialize their data.');
    } on FirebaseAuthException catch (e) {
      // This will now only report errors from the actual user creation process.
      print('AuthService: Sign up failed: ${e.message}');
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}