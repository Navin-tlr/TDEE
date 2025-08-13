import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/features/auth/auth_provider.dart';

class WeightLogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? _uid;

  WeightLogService(this._uid);

  Future<void> logWeight({required double weightKg}) async {
    if (_uid == null) {
      throw Exception("User is not authenticated.");
    }

    final today = DateTime.now();
    final ymdString =
        "${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}";
    final weightGrams = (weightKg * 1000).round();

    final userRef = _firestore.collection('users').doc(_uid);
    final entryRef = _firestore.collection('weight_logs').doc();

    final newEntry = {
      'uid': _uid,
      'ymd': int.parse(ymdString),
      'weight_g': weightGrams,
      'source': 'manual',
    };

    // Use a transaction to ensure atomicity.
    await _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);

      if (!userDoc.exists) {
        throw Exception("User document not found.");
      }
      
      final userData = userDoc.data()!;
      
      // Shift the previous week's weight.
      final currentSmoothedWeight = userData['w_t_g'] ?? 0;

      // For now, we'll use a simple "last value" smoothing.
      // A future enhancement would be to implement a true exponential moving average here.
      transaction.update(userRef, {
        'w_t_g': weightGrams,
        'w_t_prev_g': currentSmoothedWeight,
      });

      // Create the individual weight log entry.
      transaction.set(entryRef, newEntry);
    });
  }
}

// Provider to make the WeightLogService available to the UI.
final weightLogServiceProvider = Provider<WeightLogService>((ref) {
  final user = ref.watch(authStateProvider).value;
  return WeightLogService(user?.uid);
});