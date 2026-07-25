class_name Scoring
extends RefCounted

## PRD §5.2 — max 3 stars: 1 for finishing, 2 more from coins left over
## against thresholds authored per level. Never computed by a formula.

static func calculate_stars(level: LevelDefinition, coins_left: int, won: bool) -> int:
	if not won:
		return 0
	var stars: int = 1
	if coins_left >= level.star2_coin_threshold:
		stars += 1
	if coins_left >= level.star3_coin_threshold:
		stars += 1
	return stars


## Records a result against the save file. Best rating never decreases —
## replaying and doing worse leaves the stored rating untouched.
static func record_result(level_id: String, stars: int, coins_left: int) -> void:
	var state: LevelSaveState = SaveManager.get_level_state(level_id)
	if stars > 0:
		state.completed = true
	state.best_stars = max(state.best_stars, stars)
	state.best_coins_left = max(state.best_coins_left, coins_left)
	SaveManager.save_game()
