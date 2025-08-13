package awcta

import (
	"math"
	"strconv"
	"time"
)

// Constants from the blueprint
const (
	K_kcal_per_kg  = 7700
	GAMMA_x100     = 25 // Stored as int, used as 0.25
	BMR_FLOOR_MULT = 1.2
)

// BETA values for different tiers
var BETA = []float64{0.010, 0.005, 0.0075, 0.0125} // 0=Mini, 1=Slow, 2=Normal, 3=Aggressive

// User represents the structure of a user document in Firestore.
type User struct {
	UID                    string `firestore:"uid"`
	ETKcal                 int    `firestore:"e_t_kcal"`
	WTG                    int    `firestore:"w_t_g"`
	LastWeekWeightG        int    `firestore:"w_t_prev_g"` // Assumes this field will be populated
	HeightCM               int    `firestore:"height_cm"`
	AgeYears               int    `firestore:"age_years"`
	Sex                    string `firestore:"sex"`
	Tier                   int    `firestore:"tier"`
	CWeekKcal              int    `firestore:"c_week_kcal"`
	ConsecutiveWeeksLogged int    `firestore:"weeks_tier"` // Using 'weeks_tier' as per schema
}

// WeeklyAudit represents the structure of an audit log document.
type WeeklyAudit struct {
	UID                string    `firestore:"uid"`
	WeekStartYMD       int       `firestore:"week_start_ymd"`
	WeekEndYMD         int       `firestore:"week_end_ymd"`
	CWeekKcal          int       `firestore:"c_week_kcal"`
	WTBeforeG          int       `firestore:"w_t_before_g"`
	WTAfterG           int       `firestore:"w_t_after_g"`
	DWG                int       `firestore:"dw_g"`
	ETBeforeKcal       int       `firestore:"e_t_before_kcal"`
	ETAfterKcal        int       `firestore:"e_t_after_kcal"`
	TargetProposedKcal int       `firestore:"target_proposed_kcal"`
	Accepted           bool      `firestore:"accepted"`
	RunTimestamp       time.Time `firestore:"run_ts"`
}

// --- Private Helper Functions ---
func calculatePhysicalTDEE(avg_daily_kcal int, weight_change_kg float64) float64 {
	return float64(avg_daily_kcal) - (float64(K_kcal_per_kg)*weight_change_kg)/7.0
}
func updateTDEE(e_before float64, physical_tdee_estimate float64) float64 {
	gamma := float64(GAMMA_x100) / 100.0
	return (1.0-gamma)*e_before + gamma*physical_tdee_estimate
}
func calculateTargetDeficit(w_t_kg float64, tier int) float64 {
	if tier < 0 || tier >= len(BETA) {
		tier = 2
	}
	beta := BETA[tier]
	return beta * w_t_kg * float64(K_kcal_per_kg) / 7.0
}
func calculateBMR(w_t_kg float64, height_cm int, age_years int, sex string) float64 {
	bmr := (10.0 * w_t_kg) + (6.25 * float64(height_cm)) - (5.0 * float64(age_years))
	if sex == "M" {
		bmr += 5
	} else {
		bmr -= 161
	}
	return bmr
}
func applySafetyClamps(raw_target float64, bmr float64) float64 {
	bmr_floor := BMR_FLOOR_MULT * bmr
	return math.Max(raw_target, bmr_floor)
}

// Compute runs the full AWCTA calculation for a given user and returns an audit record.
func Compute(u User) WeeklyAudit {
	if u.WTG <= 0 || u.HeightCM <= 0 || u.AgeYears <= 0 || u.CWeekKcal < 0 {
		return WeeklyAudit{UID: u.UID, TargetProposedKcal: u.ETKcal, ETAfterKcal: u.ETKcal}
	}

	e_before := float64(u.ETKcal)
	w_t_kg := float64(u.WTG) / 1000.0
	w_prev_kg := float64(u.LastWeekWeightG) / 1000.0
	weight_change_kg := w_t_kg - w_prev_kg

	k := math.Min(1.0, float64(u.ConsecutiveWeeksLogged)/8.0)
	if math.Abs(weight_change_kg) > 1.0 {
		k = 0
	}

	physical_tdee_estimate := calculatePhysicalTDEE(u.CWeekKcal, weight_change_kg)
	e_after := updateTDEE(e_before, physical_tdee_estimate)
	deficit_per_day := calculateTargetDeficit(w_t_kg, u.Tier)
	raw_target := e_after - deficit_per_day

	bmr := calculateBMR(w_t_kg, u.HeightCM, u.AgeYears, u.Sex)
	final_target := applySafetyClamps(raw_target, bmr)

	today := time.Now().UTC()
	ymd, _ := strconv.Atoi(today.Format("20060102"))

	return WeeklyAudit{
		UID:                u.UID,
		WeekStartYMD:       ymd - 6,
		WeekEndYMD:         ymd,
		CWeekKcal:          u.CWeekKcal,
		WTBeforeG:          u.LastWeekWeightG,
		WTAfterG:           u.WTG,
		DWG:                u.WTG - u.LastWeekWeightG,
		ETBeforeKcal:       u.ETKcal,
		ETAfterKcal:        int(math.Round(e_after)),
		TargetProposedKcal: int(math.Round(final_target)),
		Accepted:           false,
		RunTimestamp:       today,
	}
}
