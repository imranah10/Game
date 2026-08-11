# LevelManager.gd
# Auto-loaded singleton for level data management
# Loads levels from JSON, provides level data to scenes

extends Node

var levels: Array = []
var current_level_id: int = 1

func _ready() -> void:
	_load_levels()
	print("[LevelManager] Loaded ", levels.size(), " levels")

func _load_levels() -> void:
	var file := FileAccess.open("res://data/levels.json", FileAccess.READ)
	if file:
		var parsed = JSON.parse_string(file.get_as_text())
		file.close()
		if parsed and typeof(parsed) == TYPE_ARRAY:
			levels = parsed
		else:
			push_error("[LevelManager] Failed to parse levels.json")
			_generate_fallback_levels()
	else:
		push_error("[LevelManager] levels.json not found!")
		_generate_fallback_levels()

func _generate_fallback_levels() -> void:
	# Generate 15 basic levels if JSON fails to load
	levels = []
	for i in 15:
		levels.append({
			"id": i + 1,
			"name": "Level " + str(i + 1),
			"target_score": 500 + (i * 200),
			"moves": 25 - (i / 3),
			"block_types": min(3 + (i / 4), 6),
			"grid_rows": 8,
			"grid_cols": 6,
			"special_blocks": [],
			"difficulty": "easy" if i < 5 else ("medium" if i < 10 else "hard"),
			"three_star_score": (500 + i * 200) * 2,
			"two_star_score": (500 + i * 200) * 1.5,
			"description": "Reach " + str(500 + i * 200) + " points!"
		})

func get_level(level_id: int) -> Dictionary:
	for level in levels:
		if level.id == level_id:
			return level
	return {}

func get_total_levels() -> int:
	return levels.size()

func get_next_level_id(level_id: int) -> int:
	if level_id < levels.size():
		return level_id + 1
	return -1  # No more levels

func set_current_level(level_id: int) -> void:
	current_level_id = level_id

func get_current_level() -> Dictionary:
	return get_level(current_level_id)

# Calculate stars based on score
func calculate_stars(level_id: int, score: int) -> int:
	var level := get_level(level_id)
	if level.is_empty():
		return 0
	if score >= int(level.three_star_score):
		return 3
	elif score >= int(level.two_star_score):
		return 2
	elif score >= int(level.target_score):
		return 1
	return 0
