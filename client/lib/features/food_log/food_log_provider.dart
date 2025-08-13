import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/features/auth/auth_provider.dart';

class FoodLogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? _uid;

  FoodLogService(this._uid);

  Future<void> logFood({
    required String name,
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
  }) async {
    if (_uid == null) {
      throw Exception("User is not authenticated.");
    }

    final today = DateTime.now();
    final ymdString =
        "${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}";
    final dailyDocId = "${_uid}_$ymdString";

    final dailyRef = _firestore.collection('food_daily').doc(dailyDocId);
    final entryRef = _firestore.collection('food_entries').doc();

    final newEntry = {
      'uid': _uid,
      'ts_epoch_ms': today.millisecondsSinceEpoch,
      'ymd': int.parse(ymdString),
      'name': name,
      'kcal': calories,
      'p_g': protein,
      'c_g': carbs,
      'f_g': fat,
      'grams': 0, // Not implemented in this UI, default to 0
      'source': 'manual',
    };

    // Use a transaction to ensure the daily summary and the new entry are updated atomically.
    await _firestore.runTransaction((transaction) async {
      final dailyDoc = await transaction.get(dailyRef);

      if (dailyDoc.exists) {
        // If the daily document exists, increment its values.
        transaction.update(dailyRef, {
          'kcal': FieldValue.increment(calories),
          'p_g': FieldValue.increment(protein),
          'c_g': FieldValue.increment(carbs),
          'f_g': FieldValue.increment(fat),
        });
      } else {
        // If it's the first entry of the day, create the document.
        transaction.set(dailyRef, {
          'uid': _uid,
          'ymd': int.parse(ymdString),
          'kcal': calories,
          'p_g': protein,
          'c_g': carbs,
          'f_g': fat,
        });
      }

      // Create the individual food entry document.
      transaction.set(entryRef, newEntry);
    });
  }
}

// Provider to make the FoodLogService available to the UI.
final foodLogServiceProvider = Provider<FoodLogService>((ref) {
  final user = ref.watch(authStateProvider).value;
  return FoodLogService(user?.uid);
});