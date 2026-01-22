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
var attack_cooldown: float = 0.0

func _ready() -> void:
	change_direction()
	if is_hostile:
		print("Zombie gespawned! Hostile: ", is_hostile, " Speed: ", speed)

func _process(delta: float) -> void:
	# Zoek speler op verschillende manieren
	if not player or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	if not player or not is_instance_valid(player):
		var nodes = get_tree().get_nodes_in_group("player")
		if nodes.size() > 0:
			player = nodes[0]
	if not player or not is_instance_valid(player):
		var main = get_parent()
		if main:
			player = main.get_node_or_null("Player")

	# Attack cooldown
	if attack_cooldown > 0:
		attack_cooldown -= delta

	# Zombies verbranden overdag
	if burns_in_sunlight:
		check_sunlight_burn(delta)

	# Hostile mobs jagen op de speler
	if is_hostile and player and is_instance_valid(player):
		var dist = global_position.distance_to(player.global_position)
		if dist < detection_range:
			chase_player(delta)
			if dist < 1.8:
				attack_player()
			return
		else:
			# Buiten detectie range - wander richting speler
			wander(delta)
			return

	# Niet hostile of geen speler - gewoon wandelen
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

			# Schade elke 0.5 seconden
			if burn_timer >= 0.5:
				burn_timer = 0.0
				take_damage(1)
				print("Zombie verbrandt!")
		else:
			is_burning = false

func wander(delta: float) -> void:
	change_direction_timer -= delta
	if change_direction_timer <= 0:
		change_direction()
		if is_hostile:
			print("Zombie nieuwe richting: ", direction, " speed: ", speed)

	if direction.length() > 0:
		position += direction * speed * delta
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
	if attack_cooldown > 0:
		return

	if player and player.has_method("take_damage"):
		attack_cooldown = 1.0  # 1 seconde tussen aanvallen
		player.take_damage(attack_damage)
		print("Zombie valt aan!")

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
