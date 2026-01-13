extends Node3D

# Movement speed in units per second
@export var speed: float = 5.0

func _process(delta: float) -> void:
	# Get input direction
	var direction := Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1

	# Normalize so diagonal movement isn't faster
	if direction.length() > 0:
		direction = direction.normalized()

		# Rotate player to face movement direction
		var target_angle = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, 10 * delta)

	# Move the player
	position += direction * speed * delta
