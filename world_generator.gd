extends Node3D

@export var chunk_size: float = 16.0
@export var render_distance: int = 3
@export var tree_density: float = 0.08
@export var flower_density: float = 0.15

var player: Node3D
var loaded_chunks: Dictionary = {}
var tree_scene: PackedScene
var flower_red_scene: PackedScene
var flower_yellow_scene: PackedScene

var grass_material: StandardMaterial3D
var dirt_material: StandardMaterial3D

func _ready() -> void:
	tree_scene = preload("res://world/tree.tscn")
	flower_red_scene = preload("res://world/flower_red.tscn")
	flower_yellow_scene = preload("res://world/flower_yellow.tscn")

	grass_material = StandardMaterial3D.new()
	grass_material.albedo_color = Color(0.35, 0.65, 0.25, 1)

	dirt_material = StandardMaterial3D.new()
	dirt_material.albedo_color = Color(0.5, 0.35, 0.2, 1)

func _process(_delta: float) -> void:
	if not player:
		player = get_parent().get_node_or_null("Player")
		return

	update_chunks()

func update_chunks() -> void:
	var player_chunk_x = floori(player.position.x / chunk_size)
	var player_chunk_z = floori(player.position.z / chunk_size)

	var chunks_to_keep: Dictionary = {}

	for x in range(player_chunk_x - render_distance, player_chunk_x + render_distance + 1):
		for z in range(player_chunk_z - render_distance, player_chunk_z + render_distance + 1):
			var chunk_key = str(x) + "_" + str(z)
			chunks_to_keep[chunk_key] = true

			if not loaded_chunks.has(chunk_key):
				generate_chunk(x, z)

	var chunks_to_remove: Array = []
	for chunk_key in loaded_chunks.keys():
		if not chunks_to_keep.has(chunk_key):
			chunks_to_remove.append(chunk_key)

	for chunk_key in chunks_to_remove:
		remove_chunk(chunk_key)

func generate_chunk(chunk_x: int, chunk_z: int) -> void:
	var chunk_key = str(chunk_x) + "_" + str(chunk_z)
	var chunk_node = Node3D.new()
	chunk_node.name = "Chunk_" + chunk_key

	var world_x = chunk_x * chunk_size
	var world_z = chunk_z * chunk_size

	var grass = MeshInstance3D.new()
	var grass_mesh = BoxMesh.new()
	grass_mesh.size = Vector3(chunk_size, 0.2, chunk_size)
	grass.mesh = grass_mesh
	grass.material_override = grass_material
	grass.position = Vector3(world_x + chunk_size / 2, 0.1, world_z + chunk_size / 2)
	chunk_node.add_child(grass)

	var dirt = MeshInstance3D.new()
	var dirt_mesh = BoxMesh.new()
	dirt_mesh.size = Vector3(chunk_size, 0.5, chunk_size)
	dirt.mesh = dirt_mesh
	dirt.material_override = dirt_material
	dirt.position = Vector3(world_x + chunk_size / 2, -0.25, world_z + chunk_size / 2)
	chunk_node.add_child(dirt)

	var rng = RandomNumberGenerator.new()
	rng.seed = hash(chunk_key)

	var num_trees = int(chunk_size * chunk_size * tree_density / 16)
	for i in range(num_trees):
		var tree = tree_scene.instantiate()
		tree.position = Vector3(
			world_x + rng.randf() * chunk_size,
			0,
			world_z + rng.randf() * chunk_size
		)
		chunk_node.add_child(tree)

	var num_flowers = int(chunk_size * chunk_size * flower_density / 4)
	for i in range(num_flowers):
		var flower: Node3D
		if rng.randf() > 0.5:
			flower = flower_red_scene.instantiate()
		else:
			flower = flower_yellow_scene.instantiate()
		flower.position = Vector3(
			world_x + rng.randf() * chunk_size,
			0.2,
			world_z + rng.randf() * chunk_size
		)
		chunk_node.add_child(flower)

	add_child(chunk_node)
	loaded_chunks[chunk_key] = chunk_node

func remove_chunk(chunk_key: String) -> void:
	if loaded_chunks.has(chunk_key):
		loaded_chunks[chunk_key].queue_free()
		loaded_chunks.erase(chunk_key)
