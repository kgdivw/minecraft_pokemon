extends Node3D

@export var mob_type: String = "cow"
@export var drop_item: String = "beef"
@export var drop_count: int = 2
@export var health: int = 3
@export var speed: float = 1.5
@export var is_hostile: bool = false
@export var attack_damage: int = 1
@export var detection_range: float = 10.0
@export var burns_in_sunlight: bool = false

var direction: Vector3 = Vector3.ZERO
var change_direction_timer: float = 0.0
var player: Node3D = null
var burn_timer: float = 0.0
var is_burning: bool = false

func _ready() -> void:
	change_direction()

func _process(delta: float) -> void:
	if not player:
		player = get_tree().get_first_node_in_group("player")
		if not player:
			var main = get_parent()
			if main:
				player = main.get_node_or_null("Player")

	# Zombies verbranden overdag
	if burns_in_sunlight:
		check_sunlight_burn(delta)

	if is_hostile and player:
		var dist = global_position.distance_to(player.global_position)
		if dist < detection_range:
			chase_player(delta)
			# Aanval speler als dichtbij
			if dist < 1.5:
				attack_player()
			return

	wander(delta)

func check_sunlight_burn(delta: float) -> void:
	var day_night = get_tree().get_first_node_in_group("day_night")
	if not day_night:
		var main = get_parent()
		if main:
			day_night = main.get_node_or_null("DayNightCycle")

	if day_night and day_night.has_method("is_daytime"):
		if day_night.is_daytime():
			is_burning = true
			burn_timer += delta

			# Brand effect - wordt rood
			modulate = Color(1.5, 0.5, 0.3)

			# Schade elke 0.5 seconden
			if burn_timer >= 0.5:
				burn_timer = 0.0
				take_damage(1)
		else:
			is_burning = false
			modulate = Color(1, 1, 1)

func wander(delta: float) -> void:
	change_direction_timer -= delta
	if change_direction_timer <= 0:
		change_direction()

	position += direction * speed * delta

	if direction.length() > 0:
		var target_angle = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, 5 * delta)

func chase_player(delta: float) -> void:
	if not player:
		return

	var to_player = player.global_position - global_position
	to_player.y = 0
	direction = to_player.normalized()

	position += direction * speed * 1.5 * delta

	var target_angle = atan2(direction.x, direction.z)
	rotation.y = lerp_angle(rotation.y, target_angle, 5 * delta)

func attack_player() -> void:
	if player and player.has_method("take_damage"):
		player.take_damage(attack_damage)

func change_direction() -> void:
	if randf() < 0.3:
		direction = Vector3.ZERO
	else:
		direction = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	change_direction_timer = randf_range(2.0, 5.0)

func take_damage(amount: int = 1) -> void:
	health -= amount

	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3(1.2, 0.8, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector3(1, 1, 1), 0.1)

	if health <= 0:
		die()

func die() -> void:
	GameData.add_item(drop_item, drop_count)

	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.3)
	tween.tween_callback(queue_free)
