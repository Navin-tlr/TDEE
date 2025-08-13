import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/features/auth/auth_provider.dart';

// A simple class to hold a data point for our chart.
class WeightDataPoint {
  final DateTime date;
  final double weightKg;

  WeightDataPoint({required this.date, required this.weightKg});
}

// Fetches and prepares the data for the weight trend chart.
final weightDataStreamProvider = StreamProvider.autoDispose<List<WeightDataPoint>>((ref) {
  final firestore = FirebaseFirestore.instance;
  final user = ref.watch(authStateProvider).value;

  if (user == null) {
    print('ChartDataProvider: No user, returning empty list');
    return Stream.value([]);
  }

  print('ChartDataProvider: Fetching weight data for user: ${user.uid}');

  // Get the date 30 days ago to create a rolling window for the chart.
  final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
  final thirtyDaysAgoYMD = int.parse(
    "${thirtyDaysAgo.year}${thirtyDaysAgo.month.toString().padLeft(2, '0')}${thirtyDaysAgo.day.toString().padLeft(2, '0')}"
  );

  print('ChartDataProvider: Querying from YMD: $thirtyDaysAgoYMD');

  final query = firestore
      .collection('weight_logs')
      .where('uid', isEqualTo: user.uid)
      .where('ymd', isGreaterThanOrEqualTo: thirtyDaysAgoYMD)
      .orderBy('ymd', descending: false);

  return query.snapshots().map((snapshot) {
    print('ChartDataProvider: Got ${snapshot.docs.length} weight log documents');
    
    final dataPoints = snapshot.docs.map((doc) {
      try {
        final data = doc.data();
        print('ChartDataProvider: Processing doc: $data');
        
        final ymd = data['ymd'].toString();
        // Parse YMD string to DateTime (format: YYYYMMDD)
        final year = int.parse(ymd.substring(0, 4));
        final month = int.parse(ymd.substring(4, 6));
        final day = int.parse(ymd.substring(6, 8));
        final date = DateTime(year, month, day);
        
        final weightKg = (data['weight_g'] as int) / 1000.0;
        
        print('ChartDataProvider: Created data point - date: $date, weight: $weightKg kg');
        return WeightDataPoint(date: date, weightKg: weightKg);
      } catch (e) {
        print('ChartDataProvider: Error processing document: $e');
        return null;
      }
    }).where((point) => point != null).cast<WeightDataPoint>().toList();
    
    print('ChartDataProvider: Returning ${dataPoints.length} valid data points');
    return dataPoints;
  });
});