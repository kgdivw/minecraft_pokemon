extends Node3D

@export var speed: float = 5.0
@export var catch_distance: float = 1.5
@export var attack_range: float = 2.5
@export var attack_cooldown: float = 0.4
@export var jump_force: float = 8.0
@export var gravity: float = 20.0
@export var fly_speed: float = 8.0

# Stats
var max_health: int = 20
var health: int = 20
var max_hunger: int = 20
var hunger: int = 20
var hunger_timer: float = 0.0

# Movement
var velocity_y: float = 0.0
var is_on_ground: bool = true
var is_flying: bool = false
var is_creative_mode: bool = false

var character_model: Node3D = null
var can_attack: bool = true
var attack_timer: float = 0.0
var damage_cooldown: float = 0.0

signal pokemon_caught(pokemon_name: String)
signal attacked()
signal health_changed(current: int, maximum: int)
signal hunger_changed(current: int, maximum: int)
signal player_died()

func _ready() -> void:
	load_selected_character()
	add_to_group("player")
	health_changed.emit(health, max_health)
	hunger_changed.emit(hunger, max_hunger)

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
	handle_attack_cooldown(delta)
	handle_damage_cooldown(delta)
	handle_hunger(delta)
	check_pokemon_catch()

func _input(event: InputEvent) -> void:
	# Aanvallen met linkermuisknop of spatie
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			attack()

	# Springen met spatie
	if event.is_action_pressed("ui_accept"):
		if is_creative_mode:
			toggle_fly()
		else:
			jump()

	# Creative mode toggle met C
	if event is InputEventKey and event.pressed and event.keycode == KEY_C:
		toggle_creative_mode()

	# Hotbar selectie met nummer toetsen
	if event is InputEventKey and event.pressed:
		if event.keycode >= KEY_1 and event.keycode <= KEY_9:
			var slot = event.keycode - KEY_1
			GameData.select_hotbar_slot(slot)

	# Eten met E (als je voedsel hebt)
	if event is InputEventKey and event.pressed and event.keycode == KEY_E:
		eat_food()

func handle_movement(delta: float) -> void:
	var direction := Vector3.ZERO

	# Keyboard input
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1

	# Touch joystick input
	var touch_controls = get_tree().get_first_node_in_group("touch_controls")
	if touch_controls and touch_controls.visible:
		var touch_dir = touch_controls.get_move_input()
		if touch_dir.length() > 0.1:
			direction.x = touch_dir.x
			direction.z = touch_dir.y

	if direction.length() > 0:
		direction = direction.normalized()
		var target_angle = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, 10 * delta)

	var current_speed = fly_speed if is_flying else speed
	position.x += direction.x * current_speed * delta
	position.z += direction.z * current_speed * delta

	# Verticale beweging
	if is_flying:
		# In creative mode: shift/ctrl om te dalen, spatie om te stijgen
		if Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_CTRL):
			position.y -= fly_speed * delta
		if Input.is_key_pressed(KEY_SPACE):
			position.y += fly_speed * delta
		position.y = max(position.y, 0.0)
	else:
		# Gravity
		if not is_on_ground:
			velocity_y -= gravity * delta

		position.y += velocity_y * delta

		if position.y <= 0:
			position.y = 0
			velocity_y = 0
			is_on_ground = true

func jump() -> void:
	if is_on_ground and not is_flying:
		velocity_y = jump_force
		is_on_ground = false

func toggle_fly() -> void:
	if is_creative_mode:
		is_flying = not is_flying
		if is_flying:
			velocity_y = 0
			print("Vliegen aan!")
		else:
			print("Vliegen uit!")

func toggle_creative_mode() -> void:
	is_creative_mode = not is_creative_mode
	if is_creative_mode:
		print("Creative mode aan!")
		health = max_health
		hunger = max_hunger
		health_changed.emit(health, max_health)
		hunger_changed.emit(hunger, max_hunger)
	else:
		is_flying = false
		# Als speler in de lucht is, laat hem vallen
		if position.y > 0:
			is_on_ground = false
		print("Survival mode aan!")

func handle_attack_cooldown(delta: float) -> void:
	if not can_attack:
		attack_timer -= delta
		if attack_timer <= 0:
			can_attack = true

func handle_damage_cooldown(delta: float) -> void:
	if damage_cooldown > 0:
		damage_cooldown -= delta

func handle_hunger(delta: float) -> void:
	if is_creative_mode:
		return

	hunger_timer += delta
	if hunger_timer >= 10.0:  # Elke 10 seconden honger
		hunger_timer = 0.0
		hunger = max(0, hunger - 1)
		hunger_changed.emit(hunger, max_hunger)

		# Als honger op is, verlies je health
		if hunger <= 0:
			take_damage(1)

func eat_food() -> void:
	var beef_count = GameData.get_item_count("beef")
	var pork_count = GameData.get_item_count("pork")

	if beef_count > 0:
		GameData.remove_item("beef", 1)
		hunger = min(max_hunger, hunger + 8)
		hunger_changed.emit(hunger, max_hunger)
		print("Vlees gegeten! Honger: " + str(hunger))
	elif pork_count > 0:
		GameData.remove_item("pork", 1)
		hunger = min(max_hunger, hunger + 8)
		hunger_changed.emit(hunger, max_hunger)
		print("Varkensvlees gegeten! Honger: " + str(hunger))

func attack() -> void:
	if not can_attack:
		return

	can_attack = false
	attack_timer = attack_cooldown
	attacked.emit()

	if character_model:
		var tween = create_tween()
		tween.tween_property(character_model, "rotation:y", 0.5, 0.1)
		tween.tween_property(character_model, "rotation:y", 0.0, 0.2)

	attack_trees()
	attack_mobs()

func attack_trees() -> void:
	var selected_item = GameData.get_selected_item()
	if selected_item != "axe" and selected_item != "sword":
		return

	var trees = get_tree().get_nodes_in_group("trees")
	for tree in trees:
		var dist = global_position.distance_to(tree.global_position)
		if dist < attack_range:
			if tree.has_method("take_damage"):
				tree.take_damage()
			break

func attack_mobs() -> void:
	var selected_item = GameData.get_selected_item()
	if selected_item != "sword":
		return

	var mobs = get_tree().get_nodes_in_group("mobs")
	for mob in mobs:
		var dist = global_position.distance_to(mob.global_position)
		if dist < attack_range:
			if mob.has_method("take_damage"):
				mob.take_damage(2)
			break

func take_damage(amount: int) -> void:
	if is_creative_mode:
		return

	if damage_cooldown > 0:
		return

	damage_cooldown = 0.5
	health = max(0, health - amount)
	health_changed.emit(health, max_health)

	# Flash rood
	if character_model:
		var tween = create_tween()
		tween.tween_property(character_model, "modulate", Color(1.5, 0.3, 0.3), 0.1)
		tween.tween_property(character_model, "modulate", Color(1, 1, 1), 0.2)

	if health <= 0:
		die()

func die() -> void:
	player_died.emit()
	print("Je bent dood!")
	# Respawn
	health = max_health
	hunger = max_hunger
	position = Vector3.ZERO
	health_changed.emit(health, max_health)
	hunger_changed.emit(hunger, max_hunger)

func check_pokemon_catch() -> void:
	var wild_pokemon = get_tree().get_nodes_in_group("wild_pokemon")

	for pokemon in wild_pokemon:
		var dist = global_position.distance_to(pokemon.global_position)
		if dist < catch_distance:
			var pokemon_name = pokemon.name.split("_")[0]
			GameData.catch_pokemon(pokemon_name)
			pokemon_caught.emit(pokemon_name)
			pokemon.queue_free()
