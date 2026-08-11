# LevelSelect.gd
# Level selection grid showing all unlocked levels with stars earned

extends Node2D

@onready var grid: GridContainer = $CanvasLayer/ScrollContainer/Grid
@onready var back_button: Button = $CanvasLayer/BackButton
@onready var stars_label: Label = $CanvasLayer/StarsLabel
@onready var coins_label: Label = $CanvasLayer/CoinsLabel

const LEVELS_PER_ROW := 5

func _ready() -> void:
	AdManager.hide_banner()
	back_button.pressed.connect(_on_back)
	
	stars_label.text = "Total Stars: " + str(SaveManager.data.total_stars)
	coins_label.text = "Coins: " + str(SaveManager.get_coins())
	
	grid.columns = LEVELS_PER_ROW
	_populate_levels()

func _populate_levels() -> void:
	for child in grid.get_children():
		child.queue_free()
	
	var total := LevelManager.get_total_levels()
	for i in total:
		var level_id := i + 1
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(140, 140)
		btn.text = str(level_id)
		btn.add_theme_font_size_override("font_size", 36)
		
		var unlocked := SaveManager.is_level_unlocked(level_id)
		btn.disabled = not unlocked
		
		var stars := SaveManager.get_level_stars(level_id)
		
		# Add stars below the number
		var vbox := VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		var num_label := Label.new()
		num_label.text = str(level_id)
		num_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		num_label.add_theme_font_size_override("font_size", 36)
		vbox.add_child(num_label)
		
		var stars_hbox := HBoxContainer.new()
		stars_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		for s in 3:
			var star := Label.new()
			star.text = "*" if s < stars else "."
			star.add_theme_font_size_override("font_size", 18)
			star.modulate = Color(1, 0.85, 0.2) if s < stars else Color(0.4, 0.4, 0.4)
			stars_hbox.add_child(star)
		vbox.add_child(stars_hbox)
		
		# Clear default text and add our vbox
		btn.text = ""
		btn.add_child(vbox)
		vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
		
		if unlocked:
			btn.pressed.connect(_on_level_pressed.bind(level_id))
		else:
			btn.modulate = Color(0.5, 0.5, 0.5, 1.0)
		
		grid.add_child(btn)

func _on_level_pressed(level_id: int) -> void:
	AudioManager.play_button_click()
	GameManager.go_to_game(level_id)

func _on_back() -> void:
	AudioManager.play_button_click()
	GameManager.go_to_main_menu()
