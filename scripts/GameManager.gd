# GameManager.gd
# Auto-loaded singleton for global game state and scene transitions

extends Node

signal scene_changed(scene_name: String)

var current_scene: String = "main_menu"

func _ready() -> void:
        process_mode = Node.PROCESS_MODE_ALWAYS
        print("[GameManager] Initialized")

func change_scene(scene_path: String, scene_name: String = "") -> void:
        current_scene = scene_name if scene_name != "" else scene_path
        get_tree().change_scene_to_file(scene_path)
        scene_changed.emit(current_scene)

# ---------- Scene paths ----------

const SCENES := {
        "main_menu": "res://scenes/Main.tscn",
        "level_select": "res://scenes/LevelSelect.tscn",
        "game": "res://scenes/Game.tscn",
        "settings": "res://scenes/Settings.tscn"
}

func go_to_main_menu() -> void:
        change_scene(SCENES.main_menu, "main_menu")
        AudioManager.play_music("menu")

func go_to_level_select() -> void:
        change_scene(SCENES.level_select, "level_select")

func go_to_game(level_id: int = -1) -> void:
        if level_id > 0:
                LevelManager.set_current_level(level_id)
        change_scene(SCENES.game, "game")

func go_to_settings() -> void:
        change_scene(SCENES.settings, "settings")

# ---------- Game flow helpers ----------

func quit_game() -> void:
        get_tree().quit()

# ---------- Process tracking ----------

var play_time_start := 0.0

func start_play_session() -> void:
        play_time_start = Time.get_unix_time_from_system()

func end_play_session() -> void:
        var duration: float = Time.get_unix_time_from_system() - play_time_start
        SaveManager.data.stats.total_play_time_sec += int(duration)
        SaveManager.save_data()

# ---------- Haptics helper ----------

func vibrate(duration_ms: int) -> void:
        AudioManager._vibrate(duration_ms)
