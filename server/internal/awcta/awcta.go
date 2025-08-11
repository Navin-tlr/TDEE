package awcta

import "math"

// Constants from the blueprint
const (
	K_kcal_per_kg  = 7700
	GAMMA_x100     = 25 // Stored as int, used as 0.25
	BMR_FLOOR_MULT = 1.2
)

// BETA values for different tiers
var BETA = []float64{0.010, 0.005, 0.0075, 0.0125} // 0=Mini, 1=Slow, 2=Normal, 3=Aggressive

// UserState holds the persistent state required for a user's calculation.
type UserState struct {
	E_t_kcal  int    // Current TDEE estimate in kcal
	W_t_g     int    // Current smoothed weight in grams
	Height_cm int    // Height in cm
	Age_years int    // Age in years
	Sex       string // "M", "F", or "O"
	Tier      int    // 0-3, corresponding to the BETA values
}

// CalculateNextTarget is the core engine. It takes the user's state and recent
// activity to calculate a new caloric target.
func CalculateNextTarget(state UserState, avg_daily_kcal int, weight_change_kg float64) int {
	// --- Step 1: Convert all inputs to float64 for calculation ---
	e_before := float64(state.E_t_kcal)
	c_week := float64(avg_daily_kcal)
	w_t_kg := float64(state.W_t_g) / 1000.0
	dw_kg := weight_change_kg
	gamma := float64(GAMMA_x100) / 100.0

	// --- Step 2: Calculate the physically-implied TDEE from the last week's data ---
	// Formula: TDEE = avg_calories - (K * weekly_weight_change_kg / 7_days)
	physical_tdee_estimate := c_week - (float64(K_kcal_per_kg)*dw_kg)/7.0

	// --- Step 3: Perform the Bayesian update to get the new TDEE estimate ---
	e_after := (1.0-gamma)*e_before + gamma*physical_tdee_estimate

	// --- Step 4: Calculate the target based on the new TDEE and the user's tier ---
	beta := BETA[state.Tier]
	deficit_per_day := beta * w_t_kg * float64(K_kcal_per_kg) / 7.0
	raw_target := e_after - deficit_per_day

	// --- Step 5: Apply safety clamps (BMR Floor) ---
	// Calculate BMR using Mifflin-St Jeor equation
	bmr := (10.0 * w_t_kg) + (6.25 * float64(state.Height_cm)) - (5.0 * float64(state.Age_years))
	if state.Sex == "M" {
		bmr += 5
	} else {
		bmr -= 161
	}

	// The BMR floor is the absolute minimum allowed target for safety
	bmr_floor := BMR_FLOOR_MULT * bmr

	// --- Step 6: Finalize the target and round to the nearest integer ---
	final_target := math.Max(raw_target, bmr_floor)

	return int(math.Round(final_target))
}