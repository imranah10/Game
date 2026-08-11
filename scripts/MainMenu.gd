# MainMenu.gd
# Main menu / title screen

extends Node2D

@onready var play_button: Button = $CanvasLayer/UI/PlayButton
@onready var settings_button: Button = $CanvasLayer/UI/SettingsButton
@onready var title_label: Label = $CanvasLayer/UI/TitleLabel
@onready var subtitle_label: Label = $CanvasLayer/UI/SubtitleLabel
@onready var coins_label: Label = $CanvasLayer/UI/CoinsLabel
@onready var backup_button: Button = $CanvasLayer/UI/BackupButton

func _ready() -> void:
        AudioManager.play_music("menu")
        AdManager.hide_banner()
        
        play_button.pressed.connect(_on_play)
        settings_button.pressed.connect(_on_settings)
        backup_button.pressed.connect(_on_backup)
        
        coins_label.text = "Coins: " + str(SaveManager.get_coins())
        
        # Animate title
        title_label.scale = Vector2(0.5, 0.5)
        var tween := create_tween()
        tween.tween_property(title_label, "scale", Vector2(1.0, 1.0), 0.6).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
        
        # Pulsing subtitle
        var pulse := create_tween().set_loops()
        pulse.tween_property(subtitle_label, "modulate:a", 0.4, 0.8)
        pulse.tween_property(subtitle_label, "modulate:a", 1.0, 0.8)

func _on_play() -> void:
        AudioManager.play_button_click()
        GameManager.go_to_level_select()

func _on_settings() -> void:
        AudioManager.play_button_click()
        GameManager.go_to_settings()

func _on_backup() -> void:
        AudioManager.play_button_click()
        var code := SaveManager.get_backup_code()
        # Show backup code in dialog
        print("[MainMenu] Backup code: ", code)
        OS.alert("Your backup code: " + code + "\n\nSave this code! On a new device, go to Settings > Restore Progress and enter this code.", "Backup Code")
