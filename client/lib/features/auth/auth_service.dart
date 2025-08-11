import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _initializerUrl = "https://tdee-runner-199954355172.asia-south1.run.app";

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      print('Sign in failed: ${e.message}');
    }
  }

  Future<void> createUserWithEmail(String email, String password) async {
    try {
      print('AuthService: Attempting to create user in Firebase Auth...');
      final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;
      print('AuthService: User created successfully in Firebase Auth. UID: ${user?.uid}');

      if (user != null) {
        print('AuthService: Getting ID Token...');
        final idToken = await user.getIdToken();
        print('AuthService: Got ID Token. Attempting to call backend initializer...');
        print('AuthService: URL: $_initializerUrl/initialize-user');

        try {
          final response = await http.post(
            Uri.parse('$_initializerUrl/initialize-user'),
            headers: {
              'Authorization': 'Bearer $idToken',
            },
          ).timeout(const Duration(seconds: 15)); // Add a timeout

          if (response.statusCode == 200) {
            print('AuthService: Successfully initialized user data on the backend.');
          } else {
            print('AuthService: !!! BACKEND CALL FAILED !!!');
            print('AuthService: Status Code: ${response.statusCode}');
            print('AuthService: Response Body: ${response.body}');
          }
        } on TimeoutException catch (e) {
            print('AuthService: !!! HTTP call timed out: $e');
        } on http.ClientException catch (e) {
            print('AuthService: !!! HTTP ClientException: $e');
        } catch (e) {
          print('AuthService: !!! An unknown error occurred during the HTTP call: $e');
        }
      }
    } on FirebaseAuthException catch (e) {
      print('AuthService: Sign up failed: ${e.message}');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}