import 'package:client/features/auth/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Flutter's widget binding is initialized before any async operations.
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with the platform-specific options.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Wrap the entire application in a ProviderScope to make Riverpod providers
  // available throughout the widget tree.
  runApp(const ProviderScope(child: TDEEApp()));
}

class TDEEApp extends StatelessWidget {
  const TDEEApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TDEE Adaptive Calorie App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      // The AuthWrapper is the home widget. It will decide whether to show
      // the LoginScreen or the DashboardScreen based on the auth state.
      home: const AuthWrapper(),
    );
  }
}