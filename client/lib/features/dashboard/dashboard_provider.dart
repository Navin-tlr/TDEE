import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/features/auth/auth_provider.dart';
import 'package:client/features/dashboard/daily_stats.dart';

// This StreamProvider now returns a strongly-typed DailyStats object.
final dailyStatsProvider = StreamProvider.autoDispose<DailyStats>((ref) {
  final firestore = FirebaseFirestore.instance;
  final user = ref.watch(authStateProvider).value;

  if (user == null) {
    return Stream.value(DailyStats.initial());
  }

  final userId = user.uid;
  
  // This provider now listens ONLY to the user document. 
  // The daily food log data is read by the dashboard widgets themselves.
  final userDocStream = firestore.collection('users').doc(userId).snapshots();

  // Combine the streams to build a complete DailyStats object.
  return userDocStream.asyncMap((userDoc) async {
    // We get the daily stats separately now
    final dailyStatsDocId = "${userId}_${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}";
    final foodDoc = await firestore.collection('food_daily').doc(dailyStatsDocId).get();
    
    final userData = userDoc.data() ?? {};
    final foodData = foodDoc.data() ?? {};

    // Merge data from both documents into a single map.
    final combinedData = {...userData, ...foodData};

    return DailyStats.fromFirestore(combinedData);
  });
});