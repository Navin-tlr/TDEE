// A simple data class to hold the relevant stats for the dashboard UI.
class DailyStats {
  final int currentCalories;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;
  final int? nextTargetKcal;
  final int? lastApprovedKcal;
  final bool isApproved;

  DailyStats({
    required this.currentCalories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    this.nextTargetKcal,
    this.lastApprovedKcal,
    required this.isApproved,
  });

  // A factory constructor to create an instance from a Firestore snapshot.
  factory DailyStats.fromFirestore(Map<String, dynamic> data) {
    return DailyStats(
      currentCalories: data['kcal'] as int? ?? 0,
      proteinGrams: data['p_g'] as int? ?? 0,
      carbsGrams: data['c_g'] as int? ?? 0,
      fatGrams: data['f_g'] as int? ?? 0,
      nextTargetKcal: data['next_target_kcal'] as int?,
      lastApprovedKcal: data['last_approved_kcal'] as int?,
      isApproved: data['approved'] as bool? ?? true,
    );
  }

  // A factory for a default/empty state.
  factory DailyStats.initial() {
    return DailyStats(
      currentCalories: 0,
      proteinGrams: 0,
      carbsGrams: 0,
      fatGrams: 0,
      nextTargetKcal: null,
      lastApprovedKcal: null,
      isApproved: true,
    );
  }
}