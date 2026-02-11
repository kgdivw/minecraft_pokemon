extends CanvasLayer

# Joystick variabelen
var joystick_touch_index: int = -1
var joystick_center: Vector2
var joystick_current: Vector2
var joystick_radius: float = 80.0
var joystick_dead_zone: float = 20.0

# Input values (te lezen door player)
var move_direction: Vector2 = Vector2.ZERO

# Knoppen
var attack_pressed: bool = false
var jump_pressed: bool = false
var eat_pressed: bool = false

@onready var joystick_base = $Container/JoystickBase
@onready var joystick_knob = $Container/JoystickBase/JoystickKnob
@onready var attack_button = $Container/AttackButton
@onready var jump_button = $Container/JumpButton
@onready var eat_button = $Container/EatButton

func _ready() -> void:
	add_to_group("touch_controls")

	# Alleen tonen op touch devices
	if not is_touch_device():
		visible = false
		return

	joystick_center = joystick_base.position + joystick_base.size / 2
	joystick_current = joystick_center

	# Connect button signals
	attack_button.pressed.connect(_on_attack_pressed)
	attack_button.button_up.connect(_on_attack_released)
	jump_button.pressed.connect(_on_jump_pressed)
	jump_button.button_up.connect(_on_jump_released)
	eat_button.pressed.connect(_on_eat_pressed)
	eat_button.button_up.connect(_on_eat_released)

func is_touch_device() -> bool:
	# Check of we op Android/iOS draaien
	return OS.get_name() in ["Android", "iOS"] or OS.has_feature("mobile")

func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventScreenTouch:
		handle_touch(event)
	elif event is InputEventScreenDrag:
		handle_drag(event)

func handle_touch(event: InputEventScreenTouch) -> void:
	var touch_pos = event.position
	var joystick_area = Rect2(joystick_base.position, joystick_base.size)

	if event.pressed:
		# Check of touch in joystick gebied is
		if joystick_area.has_point(touch_pos) or touch_pos.distance_to(joystick_center) < joystick_radius * 2:
			joystick_touch_index = event.index
			update_joystick(touch_pos)
	else:
		# Touch released
		if event.index == joystick_touch_index:
			joystick_touch_index = -1
			reset_joystick()

func handle_drag(event: InputEventScreenDrag) -> void:
	if event.index == joystick_touch_index:
		update_joystick(event.position)

func update_joystick(touch_pos: Vector2) -> void:
	var delta = touch_pos - joystick_center
	var distance = delta.length()

	if distance > joystick_radius:
		delta = delta.normalized() * joystick_radius

	joystick_current = joystick_center + delta
	joystick_knob.position = delta

	# Bereken move direction
	if distance > joystick_dead_zone:
		move_direction = delta.normalized()
	else:
		move_direction = Vector2.ZERO

func reset_joystick() -> void:
	joystick_knob.position = Vector2.ZERO
	joystick_current = joystick_center
	move_direction = Vector2.ZERO

func _on_attack_pressed() -> void:
	attack_pressed = true
	# Simuleer input event
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("attack"):
		player.attack()

func _on_attack_released() -> void:
	attack_pressed = false

func _on_jump_pressed() -> void:
	jump_pressed = true
	var player = get_tree().get_first_node_in_group("player")
	if player:
		if player.is_creative_mode:
			player.toggle_fly()
		else:
			player.jump()

func _on_jump_released() -> void:
	jump_pressed = false

func _on_eat_pressed() -> void:
	eat_pressed = true
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("eat_food"):
		player.eat_food()

func _on_eat_released() -> void:
	eat_pressed = false

func get_move_input() -> Vector2:
	return move_direction
