# HUD.gd
# Heads-up display shown during gameplay
# Shows score, moves, target, next block preview, and chain popups

extends CanvasLayer

@onready var score_label: Label = $Control/TopBar/ScoreContainer/ScoreLabel
@onready var target_label: Label = $Control/TopBar/ScoreContainer/TargetLabel
@onready var moves_label: Label = $Control/TopBar/MovesContainer/MovesLabel
@onready var level_label: Label = $Control/TopBar/LevelLabel
@onready var progress_bar: ProgressBar = $Control/TopBar/ProgressBar
@onready var chain_popup: Label = $Control/ChainPopup
@onready var pause_button: Button = $Control/TopBar/PauseButton

func _ready() -> void:
	chain_popup.modulate.a = 0.0
	pause_button.pressed.connect(_on_pause_pressed)

func update_score(new_score: int, target: int) -> void:
	score_label.text = str(new_score)
	target_label.text = "/ " + str(target)
	progress_bar.max_value = target
	progress_bar.value = min(new_score, target)

func update_moves(moves: int) -> void:
	moves_label.text = str(moves)
	# Visual warning when low on moves
	if moves <= 3:
		moves_label.add_theme_color_override("font_color", Color(0.95, 0.3, 0.3))
	else:
		moves_label.add_theme_color_override("font_color", Color.WHITE)

func set_level(level_id: int) -> void:
	level_label.text = "Level " + str(level_id)

func show_chain_popup(combo: int, score_gained: int) -> void:
	chain_popup.text = str(combo) + "x CHAIN!  +" + str(score_gained)
	chain_popup.modulate.a = 1.0
	chain_popup.scale = Vector2(0.5, 0.5)
	
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(chain_popup, "scale", Vector2(1.2, 1.2), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(chain_popup, "modulate:a", 0.0, 1.0).set_delay(0.5)
	
	AudioManager._vibrate(50)

func _on_pause_pressed() -> void:
	# Pause menu logic
	get_tree().paused = true
	# In production: show pause menu overlay
	print("[HUD] Pause pressed")
