# Block.gd
# A single aura block in the game grid
# 
# Block types have different colors and "aura" values.
# When two same-type blocks touch, they merge into the next tier.
# Higher-tier blocks explode and create chain reactions.

extends RigidBody2D

signal merged(block: Node)
signal exploded(block: Node, chain_count: int)

# Block tiers (1=smallest, 6=biggest/exploding)
# Tier 1 (red) -> Tier 2 (orange) -> Tier 3 (yellow) -> Tier 4 (green) -> Tier 5 (blue) -> Tier 6 (purple, explodes)
const TIER_COLORS := {
	1: Color(0.95, 0.35, 0.35),   # red
	2: Color(0.95, 0.65, 0.30),   # orange
	3: Color(0.95, 0.90, 0.35),   # yellow
	4: Color(0.40, 0.90, 0.50),   # green
	5: Color(0.40, 0.65, 0.95),   # blue
	6: Color(0.70, 0.40, 0.95)    # purple (exploding tier)
}

const TIER_SCORES := {
	1: 10, 2: 25, 3: 50, 4: 100, 5: 200, 6: 500
}

const TIER_RADIUS := {
	1: 28.0, 2: 38.0, 3: 50.0, 4: 64.0, 5: 80.0, 6: 100.0
}

var tier: int = 1
var block_id: int = 0
var is_exploding: bool = false
var merge_animation_time: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var aura_particles: CPUParticles2D = $AuraParticles
@onready var label: Label = $Label

func setup(t: int, id: int) -> void:
	tier = clamp(t, 1, 6)
	block_id = id
	_update_visuals()

func _update_visuals() -> void:
	var radius := TIER_RADIUS[tier]
	
	# Update collision shape
	if collision:
		var shape := CircleShape2D.new()
		shape.radius = radius
		collision.shape = shape
	
	# Update sprite (programmatic circle)
	if sprite:
		var tex := _generate_circle_texture(radius, TIER_COLORS[tier])
		sprite.texture = tex
		sprite.modulate = Color(1, 1, 1, 1)
	
	# Update aura particles
	if aura_particles:
		aura_particles.color = TIER_COLORS[tier]
		aura_particles.emission_sphere_radius = radius * 0.8
		aura_particles.amount = 5 + tier * 2
	
	# Update label
	if label:
		label.text = str(tier)
		label.add_theme_font_size_override("font_size", int(radius * 0.6))

func _generate_circle_texture(radius: float, color: Color) -> ImageTexture:
	var size := int(radius * 2 + 4)
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var center := Vector2(size / 2.0, size / 2.0)
	
	for y in size:
		for x in size:
			var dist := Vector2(x, y).distance_to(center)
			if dist <= radius:
				# Gradient: brighter in center
				var t := 1.0 - (dist / radius)
				var c := color.lerp(Color.WHITE, t * 0.3)
				# Soft glow at edge
				if dist > radius - 4:
					c.a = 1.0 - ((dist - (radius - 4)) / 4.0) * 0.5
				img.set_pixel(x, y, c)
			elif dist <= radius + 2:
				# Glow halo
				var glow_alpha := 1.0 - ((dist - radius) / 2.0)
				img.set_pixel(x, y, Color(color.r, color.g, color.b, glow_alpha * 0.3))
	
	var tex := ImageTexture.create_from_image(img)
	return tex

func get_score_value() -> int:
	return TIER_SCORES[tier]

func get_radius() -> float:
	return TIER_RADIUS[tier]

# Merge with another block of same tier
func can_merge_with(other: Node) -> bool:
	if other == null or not other is Block:
		return false
	if is_exploding or other.is_exploding:
		return false
	return other.tier == tier and other.tier < 6

func merge_into() -> int:
	# Returns the new tier after merge
	if tier >= 6:
		return 6  # Will explode
	return tier + 1

func trigger_explosion(chain_count: int) -> void:
	if is_exploding:
		return
	is_exploding = true
	exploded.emit(self, chain_count)
	
	# Visual: scale up and fade
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "scale", Vector2(2.0, 2.0), 0.3)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
	tween.tween_property(self, "scale", Vector2(2.0, 2.0), 0.3)
	
	# Boost particles
	if aura_particles:
		aura_particles.amount = 30
		aura_particles.explosiveness = 1.0
		aura_particles.one_shot = true
		aura_particles.emitting = true
	
	await tween.finished
	queue_free()

func play_merge_animation() -> void:
	# Brief scale pop
	var original_scale := scale
	var tween := create_tween()
	tween.tween_property(self, "scale", original_scale * 1.3, 0.1)
	tween.tween_property(self, "scale", original_scale, 0.15)
