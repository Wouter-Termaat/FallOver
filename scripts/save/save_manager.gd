extends Node

## Autoload. PRD §11 — reads/writes SaveData to user://, survives app
## restart, fails gracefully to defaults on a missing or corrupt file
## rather than crashing.

const SAVE_PATH: String = "user://save.tres"

var data: SaveData = SaveData.new()


func _ready() -> void:
	load_game()


func save_game() -> void:
	var err: Error = ResourceSaver.save(data, SAVE_PATH)
	if err != OK:
		push_error("SaveManager: failed to save (error %d) — continuing with in-memory data" % err)


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		data = SaveData.new()
		return
	var loaded: Resource = ResourceLoader.load(SAVE_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)
	if loaded == null or not (loaded is SaveData) or loaded.save_format_version != SaveData.CURRENT_VERSION:
		# Missing, corrupt, or an unmigrated older version — no migration path
		# exists yet (this is version 1, the first ever shipped), so fail
		# gracefully to defaults rather than crash or half-load garbage.
		push_warning("SaveManager: no valid save found, starting fresh")
		data = SaveData.new()
		return
	data = loaded


func get_level_state(level_id: String) -> LevelSaveState:
	if not data.level_states.has(level_id):
		data.level_states[level_id] = LevelSaveState.new()
	return data.level_states[level_id]
