extends Node

@export var spawn_interval: float = 2.0
@export var spawn_radius_min: float = 12.0
@export var spawn_radius_max: float = 25.0
@export var max_friendly_mobs: int = 15
@export var max_hostile_mobs: int = 8
@export var despawn_distance: float = 40.0

var player: Node3D
var day_night_cycle: Node
var spawn_timer: float = 0.0
var mob_id_counter: int = 0

var friendly_mob_scenes: Array[PackedScene] = []
var hostile_mob_scenes: Array[PackedScene] = []

func _ready() -> void:
	friendly_mob_scenes = [
		preload("res://mobs/cow.tscn"),
		preload("res://mobs/pig.tscn"),
		preload("res://mobs/sheep.tscn"),
	]
	hostile_mob_scenes = [
		preload("res://mobs/zombie.tscn"),
	]

	# Spawn een paar mobs bij de start
	call_deferred("spawn_initial_mobs")

func spawn_initial_mobs() -> void:
	for i in range(5):
		spawn_mob_at_random_position(false)

func _process(delta: float) -> void:
	if not player:
		player = get_parent().get_node_or_null("Player")
		return

	if not day_night_cycle:
		day_night_cycle = get_parent().get_node_or_null("DayNightCycle")

	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		spawn_mob()

	despawn_far_mobs()

func spawn_mob() -> void:
	var is_night = false
	if day_night_cycle and day_night_cycle.has_method("is_daytime"):
		is_night = not day_night_cycle.is_daytime()

	var friendly_count = get_tree().get_nodes_in_group("friendly_mobs").size()
	var hostile_count = get_tree().get_nodes_in_group("hostile_mobs").size()

	# 's Nachts spawn meer zombies
	if is_night and hostile_count < max_hostile_mobs:
		spawn_mob_at_random_position(true)
	# Overdag spawn meer vriendelijke mobs
	elif friendly_count < max_friendly_mobs:
		spawn_mob_at_random_position(false)

func spawn_mob_at_random_position(hostile: bool) -> void:
	if not player:
		return

	var angle = randf() * TAU
	var distance = randf_range(spawn_radius_min, spawn_radius_max)

	var spawn_pos = Vector3(
		player.position.x + cos(angle) * distance,
		0,
		player.position.z + sin(angle) * distance
	)

	var mob: Node3D
	if hostile:
		var scene_index = randi() % hostile_mob_scenes.size()
		mob = hostile_mob_scenes[scene_index].instantiate()
	else:
		var scene_index = randi() % friendly_mob_scenes.size()
		mob = friendly_mob_scenes[scene_index].instantiate()

	mob.name = mob.name + "_" + str(mob_id_counter)
	mob_id_counter += 1
	mob.position = spawn_pos

	get_parent().add_child(mob)

func despawn_far_mobs() -> void:
	var all_mobs = get_tree().get_nodes_in_group("mobs")

	for mob in all_mobs:
		if not is_instance_valid(mob):
			continue
		var dist = player.position.distance_to(mob.position)
		if dist > despawn_distance:
			mob.queue_free()
