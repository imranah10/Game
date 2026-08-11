# Game.gd
# Main game scene controller
# Handles block spawning, merging, scoring, level progression, and ad integration
# 
# Core gameplay loop:
# 1. Player taps above the drop zone to set angle/position
# 2. Block falls and physics applies
# 3. Same-tier blocks that touch merge into next tier
# 4. Tier-6 blocks explode, creating chain reactions
# 5. Score is calculated; level completes when target_score reached
# 6. Game over when moves run out OR blocks overflow

extends Node2D

signal score_changed(score: int)
signal moves_changed(moves: int)
signal level_completed(score: int, stars: int)
signal game_over(score: int)

# ---------- Node references ----------
@onready var drop_zone: Area2D = $DropZone
@onready var blocks_container: Node2D = $BlocksContainer
@onready var walls: StaticBody2D = $Walls
@onready var hud: CanvasLayer = $HUD
@onready var game_over_ui: CanvasLayer = $GameOverUI
@onready var level_complete_ui: CanvasLayer = $LevelCompleteUI
@onready var ad_overlay: ColorRect = $AdOverlay
@onready var ad_label: Label = $AdOverlay/AdLabel
@onready var next_block_preview: Sprite2D = $NextBlockPreview

# ---------- Game state ----------
var level_data: Dictionary = {}
var score: int = 0
var moves_left: int = 0
var blocks: Array[Block] = []
var next_block_tier: int = 1
var block_id_counter: int = 0
var is_game_active: bool = false
var is_processing_merge: bool = false
var chain_combo: int = 0

# ---------- Config ----------
const DROP_Y := 200.0  # Y position where blocks spawn
const SPAWN_COOLDOWN := 0.4
var last_spawn_time: float = 0.0

# ---------- Init ----------

func _ready() -> void:
	level_data = LevelManager.get_current_level()
	if level_data.is_empty():
		push_error("No level data!")
		return
	
	score = 0
	moves_left = int(level_data.get("moves", 20))
	next_block_tier = _pick_random_tier()
	
	_update_hud()
	_setup_walls()
	
	is_game_active = true
	GameManager.start_play_session()
	
	AdManager.load_banner()
	AdManager.show_banner()
	
	# Connect signals
	AdManager.rewarded_ad_completed.connect(_on_rewarded_ad_completed)
	AdManager.interstitial_closed.connect(_on_interstitial_closed)
	
	AudioManager.play_music("game")
	
	print("[Game] Level ", level_data.id, " started. Target: ", level_data.target_score, " | Moves: ", moves_left)

func _setup_walls() -> void:
	# Walls are configured in scene; just ensure collision is on
	pass

func _pick_random_tier() -> int:
	# Weighted random: lower tiers more common
	var max_tier := int(level_data.get("block_types", 4))
	max_tier = min(max_tier, 5)  # tier 6 only via merge
	var weights := [40, 25, 15, 10, 5]  # tiers 1-5
	var total := 0
	for i in min(max_tier, weights.size()):
		total += weights[i]
	var r := randi() % total
	var cumulative := 0
	for i in min(max_tier, weights.size()):
		cumulative += weights[i]
		if r < cumulative:
			return i + 1
	return 1

# ---------- Input / Spawn ----------

func _input(event: InputEvent) -> void:
	if not is_game_active or is_processing_merge:
		return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_spawn_block_at(event.position.x)
	elif event is InputEventScreenTouch and event.pressed:
		_spawn_block_at(event.position.x)

func _spawn_block_at(x: float) -> void:
	if moves_left <= 0:
		return
	
	var now := Time.get_unix_time_from_system()
	if now - last_spawn_time < SPAWN_COOLDOWN:
		return
	last_spawn_time = now
	
	# Clamp X within walls
	var viewport_w := get_viewport_rect().size.x
	x = clamp(x, 80, viewport_w - 80)
	
	# Spawn the next block
	var block_scene := preload("res://scenes/Block.tscn")
	var block: Block = block_scene.instantiate()
	blocks_container.add_child(block)
	block.global_position = Vector2(x, DROP_Y)
	block.setup(next_block_tier, block_id_counter)
	block_id_counter += 1
	blocks.append(block)
	
	AudioManager.play_drop()
	
	# Decrement moves
	moves_left -= 1
	_update_hud()
	
	# Update next block preview
	next_block_tier = _pick_random_tier()
	_update_next_preview()
	
	# Check for merges after a short delay (let physics settle)
	is_processing_merge = true
	await get_tree().create_timer(0.3).timeout
	_check_merges()
	
	# Check game state
	_check_game_state()

# ---------- Merge detection ----------

func _check_merges() -> void:
	chain_combo = 0
	var merged_any := true
	var total_chain_score := 0
	
	while merged_any:
		merged_any = false
		var to_merge: Dictionary = {}  # block -> [other_block]
		var to_remove: Array[Block] = []
		
		# Find all pairs of touching same-tier blocks
		for i in blocks.size():
			var b1 := blocks[i]
			if b1 == null or b1.is_exploding or b1 in to_remove:
				continue
			for j in range(i + 1, blocks.size()):
				var b2 := blocks[j]
				if b2 == null or b2.is_exploding or b2 in to_remove:
					continue
				if b1.can_merge_with(b2):
					var dist := b1.global_position.distance_to(b2.global_position)
					if dist <= (b1.get_radius() + b2.get_radius()) * 0.95:
						to_merge[b1] = b2
						to_remove.append(b2)
						merged_any = true
						break
			if b1 in to_merge:
				break  # Process this pair, then re-scan
		
		if merged_any:
			chain_combo += 1
			for b1 in to_merge:
				var b2: Block = to_merge[b1]
				# B1 absorbs B2 and upgrades tier
				var new_tier := b1.merge_into()
				var base_score := b1.get_score_value() + b2.get_score_value()
				var chain_multiplier := 1.0 + (chain_combo - 1) * 0.5  # 1x, 1.5x, 2x, 2.5x...
				var gained := int(base_score * chain_multiplier)
				score += gained
				total_chain_score += gained
				
				if new_tier >= 6:
					# Explode!
					b1.trigger_explosion(chain_combo)
					# Explosion pushes nearby blocks
					_apply_explosion_force(b1.global_position, 300.0, 400.0)
					AudioManager.play_explosion()
					SaveManager.data.stats.chain_reactions += 1
				else:
					b1.setup(new_tier, b1.block_id)
					b1.play_merge_animation()
					AudioManager.play_merge(1.0 + (new_tier - 1) * 0.15)
				
				# Remove b2
				b2.queue_free()
				blocks.erase(b2)
				SaveManager.data.stats.blocks_merged += 1
		
		_update_hud()
		# Brief delay between chain steps for visual effect
		if merged_any:
			await get_tree().create_timer(0.2).timeout
	
	if chain_combo >= 2:
		_show_chain_popup(chain_combo, total_chain_score)
	
	is_processing_merge = false

func _apply_explosion_force(center: Vector2, radius: float, force: float) -> void:
	for block in blocks:
		if block == null or block.is_exploding:
			continue
		var dist := block.global_position.distance_to(center)
		if dist < radius and dist > 0:
			var direction := (block.global_position - center).normalized()
			block.apply_impulse(direction * force * (1.0 - dist / radius))

func _show_chain_popup(combo: int, score_gained: int) -> void:
	# In production: show animated popup like "2x CHAIN! +250"
	print("[Game] ", combo, "x CHAIN! +", score_gained, " points")
	hud.show_chain_popup(combo, score_gained)

# ---------- Game state checks ----------

func _check_game_state() -> void:
	# Level complete check
	if score >= int(level_data.target_score):
		_level_complete()
		return
	
	# Moves exhausted
	if moves_left <= 0:
		# Wait for physics to settle, then check if any merges still happening
		await get_tree().create_timer(1.0).timeout
		if score >= int(level_data.target_score):
			_level_complete()
		else:
			_game_over()
		return
	
	# Overflow check: if any block goes above the danger line
	var danger_y := DROP_Y - 50
	for block in blocks:
		if block != null and not block.is_exploding and block.global_position.y < danger_y and block.linear_velocity.length() < 5.0:
			_game_over()
			break

# ---------- Level complete / Game over ----------

func _level_complete() -> void:
	if not is_game_active:
		return
	is_game_active = false
	GameManager.end_play_session()
	
	var stars := LevelManager.calculate_stars(level_data.id, score)
	SaveManager.complete_level(level_data.id, stars, score)
	
	AudioManager.play_level_complete()
	
	# Play star sounds in sequence
	for i in stars:
		await get_tree().create_timer(0.4).timeout
		AudioManager.play_star_earned(i + 1)
	
	level_complete_ui.show_results(score, stars, level_data)
	level_completed.emit(score, stars)

func _game_over() -> void:
	if not is_game_active:
		return
	is_game_active = false
	GameManager.end_play_session()
	
	AudioManager.play_game_over()
	
	# Show interstitial ad (every 3rd game over)
	AdManager.show_interstitial()
	await AdManager.interstitial_closed
	
	game_over_ui.show(score, level_data, moves_left == 0)
	game_over.emit(score)

# ---------- Rewarded ads ----------

func _on_rewarded_ad_completed(reward_type: String, amount: int) -> void:
	match reward_type:
		"extra_moves":
			moves_left += amount
			_update_hud()
			is_game_active = true
			game_over_ui.hide()
		"level_skip":
			# Skip current level with 1 star
			var stars := 1
			SaveManager.complete_level(level_data.id, stars, score)
			GameManager.go_to_level_select()
		"double_coins":
			SaveManager.add_coins(amount * SaveManager.get_coins())

func _on_interstitial_closed() -> void:
	# Continue with game over flow
	pass

# ---------- Public methods (called by UI) ----------

func watch_ad_for_extra_moves() -> void:
	AdManager.show_rewarded_ad("extra_moves")
	ad_overlay.visible = true
	ad_label.text = "Loading ad..."
	await AdManager.rewarded_ad_completed
	ad_overlay.visible = false

func watch_ad_for_skip() -> void:
	AdManager.show_rewarded_ad("level_skip")
	ad_overlay.visible = true
	ad_label.text = "Loading ad..."
	await AdManager.rewarded_ad_completed
	ad_overlay.visible = false

# ---------- HUD updates ----------

func _update_hud() -> void:
	score_changed.emit(score)
	moves_changed.emit(moves_left)
	if hud:
		hud.update_score(score, int(level_data.target_score))
		hud.update_moves(moves_left)

func _update_next_preview() -> void:
	# Update visual preview of next block
	if next_block_preview:
		var tex := _make_preview_texture(next_block_tier)
		next_block_preview.texture = tex

func _make_preview_texture(tier: int) -> ImageTexture:
	var radius := 30.0
	var img := Image.create(int(radius * 2 + 4), int(radius * 2 + 4), false, Image.FORMAT_RGBA8)
	var center := Vector2((radius * 2 + 4) / 2.0, (radius * 2 + 4) / 2.0)
	var color: Color = Block.TIER_COLORS[tier]
	for y in img.get_height():
		for x in img.get_width():
			var dist := Vector2(x, y).distance_to(center)
			if dist <= radius:
				img.set_pixel(x, y, color.lerp(Color.WHITE, 1.0 - dist / radius * 0.3))
	return ImageTexture.create_from_image(img)

func _exit_tree() -> void:
	AdManager.hide_banner()
