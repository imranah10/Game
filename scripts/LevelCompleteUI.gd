# LevelCompleteUI.gd
# Level complete screen with stars animation and next level button

extends CanvasLayer

@onready var background: ColorRect = $Background
@onready var panel: Panel = $Panel
@onready var title_label: Label = $Panel/VBox/TitleLabel
@onready var stars_container: HBoxContainer = $Panel/VBox/StarsContainer
@onready var score_label: Label = $Panel/VBox/ScoreLabel
@onready var coins_label: Label = $Panel/VBox/CoinsLabel
@onready var next_button: Button = $Panel/VBox/NextButton
@onready var home_button: Button = $Panel/VBox/HomeButton
@onready var replay_button: Button = $Panel/VBox/ReplayButton

var star_labels: Array = []

func _ready() -> void:
	hide_all()
	
	# Create 3 star slots
	for i in 3:
		var star := Label.new()
		star.text = "*"
		star.add_theme_font_size_override("font_size", 80)
		star.modulate = Color(0.3, 0.3, 0.3)
		stars_container.add_child(star)
		star_labels.append(star)
	
	next_button.pressed.connect(_on_next)
	home_button.pressed.connect(_on_home)
	replay_button.pressed.connect(_on_replay)

func hide_all() -> void:
	background.visible = false
	panel.visible = false

func show_results(final_score: int, stars: int, level_data: Dictionary) -> void:
	background.visible = true
	panel.visible = true
	
	title_label.text = "Level " + str(level_data.id) + " Complete!"
	score_label.text = "Score: " + str(final_score)
	coins_label.text = "Coins earned: +" + str(stars * 10) + "  (Total: " + str(SaveManager.get_coins()) + ")"
	
	# Reset stars
	for star in star_labels:
		star.modulate = Color(0.3, 0.3, 0.3)
		star.scale = Vector2(0.5, 0.5)
	
	# Animate stars one by one
	for i in stars:
		await get_tree().create_timer(0.4).timeout
		var tween := create_tween()
		tween.tween_property(star_labels[i], "scale", Vector2(1.3, 1.3), 0.15).set_trans(Tween.TRANS_BACK)
		tween.tween_property(star_labels[i], "scale", Vector2(1.0, 1.0), 0.1)
		star_labels[i].modulate = Color(1.0, 0.85, 0.2)  # gold
		AudioManager.play_star_earned(i + 1)
	
	# Panel scale-in
	panel.scale = Vector2(0.5, 0.5)
	panel.modulate.a = 0.0
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(panel, "modulate:a", 1.0, 0.3)
	tween.tween_property(background, "color:a", 0.7, 0.3)
	
	# Show "Next" button only if more levels exist
	var next_id := LevelManager.get_next_level_id(level_data.id)
	next_button.visible = next_id > 0

func _on_next() -> void:
	AudioManager.play_button_click()
	var next_id := LevelManager.get_next_level_id(LevelManager.current_level_id)
	if next_id > 0:
		GameManager.go_to_game(next_id)

func _on_home() -> void:
	AudioManager.play_button_click()
	GameManager.go_to_main_menu()

func _on_replay() -> void:
	AudioManager.play_button_click()
	GameManager.go_to_game(LevelManager.current_level_id)
