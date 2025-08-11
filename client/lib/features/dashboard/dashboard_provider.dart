import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/features/auth/auth_provider.dart'; // Import auth provider to get the user's state.

// This StreamProvider will listen to our 'food_daily' collection for today's entry
// for the currently authenticated user.
final dailyStatsProvider = StreamProvider.autoDispose<DocumentSnapshot>((ref) {
  final firestore = FirebaseFirestore.instance;
  
  // Watch the authStateProvider to get the current user.
  // This ensures that if the user logs out, the stream is updated.
  final user = ref.watch(authStateProvider).value;

  // If no user is logged in, we return an empty stream to avoid errors.
  if (user == null) {
    return const Stream.empty();
  }

  // Use the REAL authenticated user ID for the document path.
  final userId = user.uid; 
  final today = DateTime.now();
  
  // Construct the document ID in the format "uid_YYYYMMDD".
  final docId = "${userId}_${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}";

  // Return a real-time stream of the specific document. The UI will
  // automatically rebuild whenever this document is created or updated.
  return firestore.collection('food_daily').doc(docId).snapshots();
});