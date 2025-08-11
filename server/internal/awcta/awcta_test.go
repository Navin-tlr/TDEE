package awcta

import "testing"

// TestAWCTACalculation_BlueprintVector verifies the end-to-end calculation
// against the known-good example from the project blueprint.
func TestAWCTACalculation_BlueprintVector(t *testing.T) {
	// ARRANGE: Set up the inputs based on the blueprint's example.
	initialState := UserState{
		E_t_kcal:  2500,  // TDEE before this week's calculation
		W_t_g:     80123,   // Current smoothed weight (80.123 kg)
		Height_cm: 180,
		Age_years: 30,
		Sex:       "M",
		Tier:      2,       // "Normal" tier
	}
	avg_calories := 2300    // Average calories consumed last week
	weight_change := -0.5 // kg change over the last week
	expected_target := 2137 // The correct, final target after all clamps

	// ACT: Run the function with the correct arguments.
	actual_target := CalculateNextTarget(initialState, avg_calories, weight_change)

	// ASSERT: Check if the result matches our expectation.
	if actual_target != expected_target {
		t.Errorf("AWCTA calculation failed: expected %d, got %d", expected_target, actual_target)
	}
}