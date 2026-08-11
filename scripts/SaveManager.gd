# SaveManager.gd
# Auto-loaded singleton for local save data (no login required)
# Uses JSON file stored in user:// directory (persistent across app updates)

extends Node

const SAVE_FILE := "user://save_data.json"

var data := {
	"version": 1,
	"levels_completed": {},        # { "1": 3, "2": 2 } -> level_id: stars_earned (0-3)
	"total_stars": 0,
	"total_score": 0,
	"highest_level_unlocked": 1,
	"coins": 0,
	"sound_enabled": true,
	"music_enabled": true,
	"haptics_enabled": true,
	"ads_watched": 0,
	"backup_code": "",             # 6-digit code for cross-device sync
	"settings": {
		"quality": "auto",
		"reduced_motion": false
	},
	"stats": {
		"games_played": 0,
		"total_play_time_sec": 0,
		"chain_reactions": 0,
		"blocks_merged": 0
	}
}

func _ready() -> void:
	load_data()

func load_data() -> void:
	var file := FileAccess.open(SAVE_FILE, FileAccess.READ)
	if file:
		var parsed = JSON.parse_string(file.get_as_text())
		file.close()
		if parsed and typeof(parsed) == TYPE_DICTIONARY:
			# Merge loaded data over defaults (handles new fields added in updates)
			_deep_merge(data, parsed)
			print("[SaveManager] Data loaded. Stars: ", data.total_stars, " | Coins: ", data.coins)
		else:
			print("[SaveManager] Save file corrupted, using defaults.")
	else:
		print("[SaveManager] No save file found, using defaults.")

func save_data() -> void:
	var file := FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()
	else:
		push_error("[SaveManager] Could not write save file!")

func _deep_merge(target: Dictionary, source: Dictionary) -> void:
	for key in source:
		if target.has(key) and typeof(target[key]) == TYPE_DICTIONARY and typeof(source[key]) == TYPE_DICTIONARY:
			_deep_merge(target[key], source[key])
		else:
			target[key] = source[key]

# ---------- Public API ----------

func get_level_stars(level_id: int) -> int:
	return data.levels_completed.get(str(level_id), 0)

func is_level_unlocked(level_id: int) -> bool:
	return level_id <= data.highest_level_unlocked

func complete_level(level_id: int, stars: int, score: int) -> void:
	var key := str(level_id)
	var prev_stars := data.levels_completed.get(key, 0) as int
	if stars > prev_stars:
		data.levels_completed[key] = stars
		data.total_stars += (stars - prev_stars)
	data.total_score += score
	data.coins += stars * 10  # 10 coins per star
	if level_id >= data.highest_level_unlocked:
		data.highest_level_unlocked = level_id + 1
	data.stats.games_played += 1
	save_data()

func add_coins(amount: int) -> void:
	data.coins += amount
	save_data()

func spend_coins(amount: int) -> bool:
	if data.coins >= amount:
		data.coins -= amount
		save_data()
		return true
	return false

func get_coins() -> int:
	return data.coins

func record_ad_watched() -> void:
	data.ads_watched += 1
	data.coins += 5  # bonus coins for watching ad
	save_data()

func toggle_sound() -> void:
	data.sound_enabled = !data.sound_enabled
	save_data()

func toggle_music() -> void:
	data.music_enabled = !data.music_enabled
	save_data()

func toggle_haptics() -> void:
	data.haptics_enabled = !data.haptics_enabled
	save_data()

# ---------- Cross-device backup (no email/phone) ----------

func generate_backup_code() -> String:
	var code := ""
	for i in 6:
		code += str(randi() % 10)
	data.backup_code = code
	save_data()
	return code

func get_backup_code() -> String:
	if data.backup_code == "":
		return generate_backup_code()
	return data.backup_code

func reset_progress() -> void:
	data = {
		"version": 1,
		"levels_completed": {},
		"total_stars": 0,
		"total_score": 0,
		"highest_level_unlocked": 1,
		"coins": 0,
		"sound_enabled": true,
		"music_enabled": true,
		"haptics_enabled": true,
		"ads_watched": 0,
		"backup_code": "",
		"settings": {"quality": "auto", "reduced_motion": false},
		"stats": {"games_played": 0, "total_play_time_sec": 0, "chain_reactions": 0, "blocks_merged": 0}
	}
	save_data()
