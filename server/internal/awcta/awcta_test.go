package awcta

import "testing"

// TestAWCTACalculation_BlueprintVector verifies the end-to-end calculation
// against the known-good example from the project blueprint.
func TestAWCTACalculation_BlueprintVector(t *testing.T) {
	// ARRANGE
	initialState := UserState{
		E_t_kcal:               2500,
		W_t_g:                  80123,
		Height_cm:              180,
		Age_years:              30,
		Sex:                    "M",
		Tier:                   2, // "Normal" tier
		ConsecutiveWeeksLogged: 8, // Assumes a mature user for k=1.0
	}
	avg_calories := 2300
	weight_change := -0.5
	expected_target := 2137

	// ACT
	actual_target := CalculateNextTarget(initialState, avg_calories, weight_change)

	// ASSERT
	if actual_target != expected_target {
		t.Errorf("Blueprint vector test failed: expected %d, got %d", expected_target, actual_target)
	}
}

// TestGainScheduling verifies that the adaptive gain 'k' is applied correctly.
func TestGainScheduling(t *testing.T) {
	// ARRANGE
	baseState := UserState{
		E_t_kcal:  2500,
		W_t_g:     80123,
		Height_cm: 180,
		Age_years: 30,
		Sex:       "M",
		Tier:      2,
	}
	avg_calories := 2300
	weight_change := -0.5

	testCases := []struct {
		name                   string
		consecutiveWeeksLogged int
		expectedTarget         int // Targets will differ due to k
	}{
		{"Week 1 (k=0.125)", 1, 2303},
		{"Week 4 (k=0.5)", 4, 2244},
		{"Week 8 (k=1.0)", 8, 2137},
		{"Week 10 (k=1.0)", 10, 2137},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			// ARRANGE
			state := baseState
			state.ConsecutiveWeeksLogged = tc.consecutiveWeeksLogged

			// ACT
			actualTarget := CalculateNextTarget(state, avg_calories, weight_change)

			// ASSERT
			if actualTarget != tc.expectedTarget {
				t.Errorf("Expected target %d, but got %d", tc.expectedTarget, actualTarget)
			}
		})
	}
}

// TestWaterNoiseGuard verifies that an implausible weight change pauses adjustments.
func TestWaterNoiseGuard(t *testing.T) {
	// ARRANGE
	initialState := UserState{
		E_t_kcal:               2500,
		W_t_g:                  80123,
		Height_cm:              180,
		Age_years:              30,
		Sex:                    "M",
		Tier:                   2,
		ConsecutiveWeeksLogged: 8,
	}
	avg_calories := 2300
	weight_change := -1.5 // Implausible change, should set k=0
	// With k=0, the target should be the new TDEE minus the deficit, but with no 'k' multiplier on the adjustment.
	// physical_tdee = 2300 - (7700 * -1.5 / 7) = 3950
	// e_after = (0.75 * 2500) + (0.25 * 3950) = 1875 + 987.5 = 2862.5
	// deficit = 0.0075 * 80.123 * 7700 / 7 = 661
	// raw_target = 2862.5 - 661 = 2201.5 -> 2202
	expected_target := 2202

	// ACT
	actual_target := CalculateNextTarget(initialState, avg_calories, weight_change)

	// ASSERT
	if actual_target != expected_target {
		t.Errorf("Water noise guard test failed: expected %d, got %d", expected_target, actual_target)
	}
}

// TestBMRFloorClamp verifies that the target doesn't drop below the BMR safety floor.
func TestBMRFloorClamp(t *testing.T) {
	// ARRANGE
	// State designed to produce a very low raw target
	initialState := UserState{
		E_t_kcal:               2000,
		W_t_g:                  90000, // 90kg
		Height_cm:              175,
		Age_years:              40,
		Sex:                    "M",
		Tier:                   3, // Aggressive
		ConsecutiveWeeksLogged: 10,
	}
	avg_calories := 1500  // Very low intake
	weight_change := -0.2 // Minimal weight loss despite low intake
	// BMR = (10*90) + (6.25*175) - (5*40) + 5 = 900 + 1093.75 - 200 + 5 = 1798.75
	// BMR Floor = 1.2 * 1798.75 = 2158.5 -> 2159
	expected_target_at_bmr_floor := 2159

	// ACT
	actual_target := CalculateNextTarget(initialState, avg_calories, weight_change)

	// ASSERT
	if actual_target != expected_target_at_bmr_floor {
		t.Errorf("BMR floor clamp test failed: expected %d, got %d", expected_target_at_bmr_floor, actual_target)
	}
}
