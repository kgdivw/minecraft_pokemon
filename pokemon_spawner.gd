extends Node

@export var spawn_interval: float = 2.0
@export var spawn_radius_min: float = 8.0
@export var spawn_radius_max: float = 20.0
@export var max_wild_pokemon: int = 10
@export var despawn_distance: float = 30.0

var player: Node3D
var spawn_timer: float = 0.0
var pokemon_id_counter: int = 0

var pokemon_scenes: Array[PackedScene] = []

func _ready() -> void:
	pokemon_scenes = [
		preload("res://pikachu.tscn"),
		preload("res://charmander.tscn"),
		preload("res://bulbasaur.tscn"),
		preload("res://squirtle.tscn"),
	]

func _process(delta: float) -> void:
	if not player:
		player = get_parent().get_node_or_null("Player")
		return

	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		try_spawn_pokemon()

	despawn_far_pokemon()

func try_spawn_pokemon() -> void:
	var wild_pokemon = get_tree().get_nodes_in_group("wild_pokemon")
	if wild_pokemon.size() >= max_wild_pokemon:
		return

	var angle = randf() * TAU
	var distance = randf_range(spawn_radius_min, spawn_radius_max)

	var spawn_pos = Vector3(
		player.position.x + cos(angle) * distance,
		0.2,
		player.position.z + sin(angle) * distance
	)

	var scene_index = randi() % pokemon_scenes.size()
	var pokemon = pokemon_scenes[scene_index].instantiate()

	var pokemon_names = ["Pikachu", "Charmander", "Bulbasaur", "Squirtle"]
	pokemon.name = pokemon_names[scene_index] + "_" + str(pokemon_id_counter)
	pokemon_id_counter += 1

	pokemon.position = spawn_pos
	pokemon.scale = Vector3(0.5, 0.5, 0.5)
	pokemon.add_to_group("wild_pokemon")

	get_parent().add_child(pokemon)

func despawn_far_pokemon() -> void:
	var wild_pokemon = get_tree().get_nodes_in_group("wild_pokemon")

	for pokemon in wild_pokemon:
		var dist = player.position.distance_to(pokemon.position)
		if dist > despawn_distance:
			pokemon.queue_free()
