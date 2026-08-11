# Settings.gd
# Settings screen - sound/music/haptics toggles, backup code, restore progress, reset

extends Node2D

@onready var sound_button: Button = $CanvasLayer/UI/VBox/SoundButton
@onready var music_button: Button = $CanvasLayer/UI/VBox/MusicButton
@onready var haptics_button: Button = $CanvasLayer/UI/VBox/HapticsButton
@onready var backup_button: Button = $CanvasLayer/UI/VBox/BackupButton
@onready var restore_button: Button = $CanvasLayer/UI/VBox/RestoreButton
@onready var reset_button: Button = $CanvasLayer/UI/VBox/ResetButton
@onready var back_button: Button = $CanvasLayer/UI/BackButton
@onready var version_label: Label = $CanvasLayer/UI/VersionLabel

func _ready() -> void:
	sound_button.pressed.connect(_on_sound)
	music_button.pressed.connect(_on_music)
	haptics_button.pressed.connect(_on_haptics)
	backup_button.pressed.connect(_on_backup)
	restore_button.pressed.connect(_on_restore)
	reset_button.pressed.connect(_on_reset)
	back_button.pressed.connect(_on_back)
	
	version_label.text = "Aura Blocks v1.0.0"
	_update_labels()

func _update_labels() -> void:
	sound_button.text = "Sound: " + ("ON" if SaveManager.data.sound_enabled else "OFF")
	music_button.text = "Music: " + ("ON" if SaveManager.data.music_enabled else "OFF")
	haptics_button.text = "Haptics: " + ("ON" if SaveManager.data.haptics_enabled else "OFF")

func _on_sound() -> void:
	AudioManager.play_button_click()
	SaveManager.toggle_sound()
	_update_labels()

func _on_music() -> void:
	AudioManager.play_button_click()
	SaveManager.toggle_music()
	_update_labels()

func _on_haptics() -> void:
	AudioManager.play_button_click()
	SaveManager.toggle_haptics()
	_update_labels()

func _on_backup() -> void:
	AudioManager.play_button_click()
	var code := SaveManager.get_backup_code()
	OS.alert("Your backup code: " + code + "\n\nSave this code to restore your progress on a new device.", "Backup Code")

func _on_restore() -> void:
	AudioManager.play_button_click()
	# In production: show text input dialog
	OS.alert("Enter your 6-digit backup code in the next prompt.", "Restore Progress")
	# This would normally open a LineEdit dialog; for prototype we use OS.alert

func _on_reset() -> void:
	AudioManager.play_button_click()
	# Confirmation dialog
	var dialog := ConfirmationDialog.new()
	dialog.dialog_text = "Reset ALL progress? This cannot be undone!"
	dialog.confirmed.connect(_do_reset)
	add_child(dialog)
	dialog.popup_centered()

func _do_reset() -> void:
	SaveManager.reset_progress()
	_update_labels()
	OS.alert("Progress reset.", "Done")

func _on_back() -> void:
	AudioManager.play_button_click()
	GameManager.go_to_main_menu()
