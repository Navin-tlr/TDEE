import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/features/auth/auth_provider.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? _uid;

  UserService(this._uid);

  // Checks if the user's profile is complete.
  Future<bool> isProfileComplete() async {
    if (_uid == null) return false;
    final doc = await _firestore.collection('users').doc(_uid).get();
    return doc.exists && doc.data()?['height_cm'] != null;
  }

  // Saves the initial user profile data.
  Future<void> saveInitialProfile({
    required int heightCm,
    required int ageYears,
    required String sex,
    required double initialWeightKg,
  }) async {
    if (_uid == null) {
      throw Exception("User is not authenticated.");
    }

    final initialWeightG = (initialWeightKg * 1000).round();
    
    // For a new user, the initial TDEE is a placeholder.
    // The first weekly run will calculate the real one.
    // A more advanced implementation might use Mifflin-St Jeor here.
    final initialTdee = 2000;

    await _firestore.collection('users').doc(_uid).set({
      'uid': _uid,
      'height_cm': heightCm,
      'age_years': ageYears,
      'sex': sex,
      'w_t_g': initialWeightG,
      'w_t_prev_g': initialWeightG, // Prev weight is the same as current initially
      'e_t_kcal': initialTdee,
      'c_week_kcal': 0,
      'weeks_tier': 0, // Start the adaptive gain counter
      'tier': 2, // Default to "Normal"
      'approved': true, // No pending changes for a new user
      'last_approved_kcal': initialTdee,
    }, SetOptions(merge: true));
  }
}

// Provider for the UserService
final userServiceProvider = Provider<UserService>((ref) {
  final user = ref.watch(authStateProvider).value;
  return UserService(user?.uid);
});

// A future provider to check the profile completion status.
final isProfileCompleteProvider = FutureProvider.autoDispose<bool>((ref) async {
  return await ref.watch(userServiceProvider).isProfileComplete();
});