# AudioManager.gd
# Auto-loaded singleton for ASMR-style sound + haptic feedback
# ASMR sounds (kinetic sand, pop-it) are KEY to making the game feel satisfying

extends Node

var audio_players: Array[AudioStreamPlayer] = []
var sfx_player: AudioStreamPlayer
var music_player: AudioStreamPlayer

# Preload sounds (replace with actual .wav/.ogg files in assets/sounds/)
# For prototype, we generate simple synthesized sounds

func _ready() -> void:
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFXPlayer"
	add_child(sfx_player)
	
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.volume_db = -8.0
	add_child(music_player)
	
	print("[AudioManager] Initialized")

# ---------- SFX ----------

func play_merge(pitch: float = 1.0) -> void:
	if not SaveManager.data.sound_enabled:
		return
	# Synthesized "pop" sound for merge
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = 44100
	stream.buffer_length = 0.1
	sfx_player.stream = stream
	sfx_player.pitch_scale = pitch
	sfx_player.play()
	_vibrate(20)

func play_drop() -> void:
	if not SaveManager.data.sound_enabled:
		return
	# Soft thud sound
	print("[Audio] drop")
	_vibrate(15)

func play_explosion() -> void:
	if not SaveManager.data.sound_enabled:
		return
	# Big explosion sound for chain reaction
	print("[Audio] explosion")
	_vibrate(50)

func play_level_complete() -> void:
	if not SaveManager.data.sound_enabled:
		return
	# Triumphant chord progression
	print("[Audio] level_complete")
	_vibrate(100)

func play_game_over() -> void:
	if not SaveManager.data.sound_enabled:
		return
	print("[Audio] game_over")

func play_button_click() -> void:
	if not SaveManager.data.sound_enabled:
		return
	_vibrate(10)

func play_star_earned(star_num: int) -> void:
	if not SaveManager.data.sound_enabled:
		return
	# Ascending pitch for each star
	print("[Audio] star_", star_num)
	_vibrate(30)

# ---------- Music ----------

func play_music(track: String = "menu") -> void:
	if not SaveManager.data.music_enabled:
		music_player.stop()
		return
	print("[Audio] music: ", track)
	# In production: load actual music files
	# music_player.stream = load("res://assets/sounds/music_" + track + ".ogg")
	# music_player.play()

func stop_music() -> void:
	music_player.stop()

# ---------- Haptics (vibration) ----------

func _vibrate(duration_ms: int) -> void:
	if not SaveManager.data.haptics_enabled:
		return
	# Production: use Android vibrator plugin
	# Input.vibrate_handheld(duration_ms)  # Godot's built-in (basic)
	# For better haptics, use Vibrate.gd Android plugin
	if OS.has_feature("android"):
		Input.vibrate_handheld(duration_ms)

# ---------- Toggle ----------

func set_sound_enabled(enabled: bool) -> void:
	SaveManager.data.sound_enabled = enabled
	if not enabled:
		sfx_player.stop()

func set_music_enabled(enabled: bool) -> void:
	SaveManager.data.music_enabled = enabled
	if not enabled:
		music_player.stop()
