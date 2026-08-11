# GameOverUI.gd
# Game over screen with rewarded ad option (extra moves / skip)

extends CanvasLayer

signal retry_pressed
signal home_pressed

@onready var background: ColorRect = $Background
@onready var panel: Panel = $Panel
@onready var title_label: Label = $Panel/VBox/TitleLabel
@onready var score_label: Label = $Panel/VBox/ScoreLabel
@onready var target_label: Label = $Panel/VBox/TargetLabel
@onready var watch_ad_button: Button = $Panel/VBox/WatchAdButton
@onready var retry_button: Button = $Panel/VBox/RetryButton
@onready var home_button: Button = $Panel/VBox/HomeButton

var game_scene: Node = null

func _ready() -> void:
	hide_all()
	watch_ad_button.pressed.connect(_on_watch_ad)
	retry_button.pressed.connect(_on_retry)
	home_button.pressed.connect(_on_home)

func hide_all() -> void:
	background.visible = false
	panel.visible = false

func show(score: int, level_data: Dictionary, out_of_moves: bool) -> void:
	background.visible = true
	panel.visible = true
	
	if out_of_moves:
		title_label.text = "Out of Moves!"
	else:
		title_label.text = "Game Over"
	
	score_label.text = "Score: " + str(score)
	target_label.text = "Target: " + str(level_data.target_score)
	
	# Show rewarded ad button prominently (this is the goldmine!)
	watch_ad_button.visible = out_of_moves
	watch_ad_button.text = " WATCH AD for +5 Moves"
	
	# Animate in
	panel.scale = Vector2(0.5, 0.5)
	panel.modulate.a = 0.0
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(panel, "modulate:a", 1.0, 0.3)
	tween.tween_property(background, "color:a", 0.7, 0.3)

func _on_watch_ad() -> void:
	watch_ad_button.disabled = true
	watch_ad_button.text = "Loading ad..."
	# Call back to the game scene to show ad
	game_scene = get_tree().current_scene
	if game_scene.has_method("watch_ad_for_extra_moves"):
		game_scene.watch_ad_for_extra_moves()
		# Wait for ad to complete, then hide UI
		await AdManager.rewarded_ad_completed
		hide_all()
		watch_ad_button.disabled = false
		watch_ad_button.text = " WATCH AD for +5 Moves"

func _on_retry() -> void:
	AudioManager.play_button_click()
	retry_pressed.emit()
	# Reload the same level
	GameManager.go_to_game(LevelManager.current_level_id)

func _on_home() -> void:
	AudioManager.play_button_click()
	home_pressed.emit()
	GameManager.go_to_main_menu()
