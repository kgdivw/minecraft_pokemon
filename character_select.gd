extends Node3D

var characters = [
	{"name": "boy1", "scene": "res://characters/boy1.tscn", "display": "Jongen 1"},
	{"name": "boy2", "scene": "res://characters/boy2.tscn", "display": "Jongen 2"},
	{"name": "boy3", "scene": "res://characters/boy3.tscn", "display": "Jongen 3"},
	{"name": "girl1", "scene": "res://characters/girl1.tscn", "display": "Meisje 1"},
	{"name": "girl2", "scene": "res://characters/girl2.tscn", "display": "Meisje 2"},
	{"name": "girl3", "scene": "res://characters/girl3.tscn", "display": "Meisje 3"},
]

var current_index = 0
var character_preview: Node3D = null

@onready var preview_position = $PreviewPosition
@onready var character_label = $UI/CharacterLabel
@onready var instruction_label = $UI/InstructionLabel
@onready var left_button = $UI/LeftButton
@onready var right_button = $UI/RightButton
@onready var start_button = $UI/StartButton

func _ready() -> void:
	load_character_preview()
	update_ui()

	# Connect button signals
	left_button.pressed.connect(_on_left_pressed)
	right_button.pressed.connect(_on_right_pressed)
	start_button.pressed.connect(_on_start_pressed)

func _on_left_pressed() -> void:
	current_index = (current_index - 1 + characters.size()) % characters.size()
	load_character_preview()
	update_ui()

func _on_right_pressed() -> void:
	current_index = (current_index + 1) % characters.size()
	load_character_preview()
	update_ui()

func _on_start_pressed() -> void:
	select_character()

func _process(_delta: float) -> void:
	if character_preview:
		character_preview.rotation.y += 0.02

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_left"):
		current_index = (current_index - 1 + characters.size()) % characters.size()
		load_character_preview()
		update_ui()
	elif event.is_action_pressed("move_right"):
		current_index = (current_index + 1) % characters.size()
		load_character_preview()
		update_ui()
	elif event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_ENTER):
		select_character()

func load_character_preview() -> void:
	if character_preview:
		character_preview.queue_free()

	var scene = load(characters[current_index]["scene"])
	character_preview = scene.instantiate()
	preview_position.add_child(character_preview)

func update_ui() -> void:
	character_label.text = characters[current_index]["display"]

func select_character() -> void:
	GameData.selected_character = characters[current_index]["name"]
	get_tree().change_scene_to_file("res://main.tscn")
