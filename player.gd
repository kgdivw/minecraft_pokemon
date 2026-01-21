extends Node3D

@export var speed: float = 5.0
@export var catch_distance: float = 1.5

var character_model: Node3D = null

signal pokemon_caught(pokemon_name: String)

func _ready() -> void:
	load_selected_character()

func load_selected_character() -> void:
	var char_name = "boy1"
	if GameData:
		char_name = GameData.selected_character

	var char_path = "res://characters/" + char_name + ".tscn"
	var scene = load(char_path)
	if scene:
		character_model = scene.instantiate()
		add_child(character_model)

func _process(delta: float) -> void:
	handle_movement(delta)
	check_pokemon_catch()

func handle_movement(delta: float) -> void:
	var direction := Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1

	if direction.length() > 0:
		direction = direction.normalized()
		var target_angle = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, 10 * delta)

	position += direction * speed * delta

func check_pokemon_catch() -> void:
	var wild_pokemon = get_tree().get_nodes_in_group("wild_pokemon")

	for pokemon in wild_pokemon:
		var dist = global_position.distance_to(pokemon.global_position)
		if dist < catch_distance:
			var pokemon_name = pokemon.name.split("_")[0]
			GameData.catch_pokemon(pokemon_name)
			pokemon_caught.emit(pokemon_name)
			pokemon.queue_free()
