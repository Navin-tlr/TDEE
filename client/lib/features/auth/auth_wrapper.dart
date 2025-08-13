import 'package:client/features/auth/auth_provider.dart';
import 'package:client/features/auth/login_screen.dart';
import 'package:client/features/navigation/main_navigation.dart';
import 'package:client/features/user_profile/onboarding_screen.dart';
import 'package:client/features/user_profile/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          print('AuthWrapper: User is logged in: ${user.uid}');
          // User is logged in, now check if their profile is complete.
          final profileComplete = ref.watch(isProfileCompleteProvider);
          return profileComplete.when(
            data: (isComplete) {
              print('AuthWrapper: Profile complete check result: $isComplete');
              if (isComplete) {
                print('AuthWrapper: Navigating to MainNavigation');
                return const MainNavigation();
              } else {
                print('AuthWrapper: Navigating to OnboardingScreen');
                return const OnboardingScreen();
              }
            },
            loading: () {
              print('AuthWrapper: Profile completion check is loading');
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            },
            error: (err, stack) {
              print('AuthWrapper: Profile completion check error: $err');
              return Scaffold(body: Center(child: Text('Error checking profile: $err')));
            },
          );
        }
        print('AuthWrapper: User is not logged in, showing LoginScreen');
        // User is not logged in, show the login screen.
        return const LoginScreen();
      },
      loading: () {
        print('AuthWrapper: Auth state is loading');
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
      error: (err, stack) {
        print('AuthWrapper: Auth state error: $err');
        return Scaffold(body: Center(child: Text('Authentication Error: $err')));
      },
    );
  }
}