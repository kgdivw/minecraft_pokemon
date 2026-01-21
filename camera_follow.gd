extends Camera3D

@export var target_path: NodePath
@export var offset: Vector3 = Vector3(0, 12, 12)
@export var smooth_speed: float = 5.0

var target: Node3D

func _ready() -> void:
	if target_path:
		target = get_node(target_path)

func _process(delta: float) -> void:
	if not target:
		target = get_parent().get_node_or_null("Player")
		if not target:
			return

	var target_position = target.global_position + offset
	global_position = global_position.lerp(target_position, smooth_speed * delta)
