extends Control

@onready var items_grid = $Panel/ItemsGrid
@onready var pokemon_grid = $Panel/PokemonGrid
@onready var close_button = $Panel/CloseButton

var is_open: bool = false

func _ready() -> void:
	visible = false
	close_button.pressed.connect(_on_close_pressed)
	GameData.inventory_changed.connect(_on_inventory_changed)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		toggle_inventory()
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if is_open:
			close_inventory()

func toggle_inventory() -> void:
	if is_open:
		close_inventory()
	else:
		open_inventory()

func open_inventory() -> void:
	is_open = true
	visible = true
	update_inventory_display()
	get_tree().paused = true

func close_inventory() -> void:
	is_open = false
	visible = false
	get_tree().paused = false

func _on_close_pressed() -> void:
	close_inventory()

func _on_inventory_changed() -> void:
	if is_open:
		update_inventory_display()

func update_inventory_display() -> void:
	# Clear existing items
	for child in items_grid.get_children():
		child.queue_free()
	for child in pokemon_grid.get_children():
		child.queue_free()

	# Add items
	for item_name in GameData.inventory.keys():
		var count = GameData.inventory[item_name]
		if count > 0:
			var item_slot = create_item_slot(item_name, count)
			items_grid.add_child(item_slot)

	# Add Pokemon
	for pokemon_name in GameData.caught_pokemon:
		var pokemon_slot = create_pokemon_slot(pokemon_name)
		pokemon_grid.add_child(pokemon_slot)

func create_item_slot(item_name: String, count: int) -> Control:
	var slot = Panel.new()
	slot.custom_minimum_size = Vector2(80, 80)

	var vbox = VBoxContainer.new()
	vbox.size = Vector2(80, 80)

	var icon = Label.new()
	icon.text = get_item_icon(item_name)
	icon.add_theme_font_size_override("font_size", 28)
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(icon)

	var name_label = Label.new()
	name_label.text = item_name.capitalize()
	name_label.add_theme_font_size_override("font_size", 12)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)

	var count_label = Label.new()
	count_label.text = "x" + str(count)
	count_label.add_theme_font_size_override("font_size", 14)
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(count_label)

	slot.add_child(vbox)
	return slot

func create_pokemon_slot(pokemon_name: String) -> Control:
	var slot = Panel.new()
	slot.custom_minimum_size = Vector2(80, 80)

	var vbox = VBoxContainer.new()
	vbox.size = Vector2(80, 80)

	var icon = Label.new()
	icon.text = get_pokemon_icon(pokemon_name)
	icon.add_theme_font_size_override("font_size", 28)
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(icon)

	var name_label = Label.new()
	name_label.text = pokemon_name.capitalize()
	name_label.add_theme_font_size_override("font_size", 12)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)

	slot.add_child(vbox)
	return slot

func get_item_icon(item_name: String) -> String:
	match item_name:
		"wood": return "🪵"
		"stone": return "🪨"
		"dirt": return "🟫"
		"coal": return "⚫"
		"iron": return "🔩"
		"diamond": return "💎"
		"beef": return "🥩"
		"pork": return "🥓"
		"wool": return "🧶"
		_: return "📦"

func get_pokemon_icon(pokemon_name: String) -> String:
	match pokemon_name.to_lower():
		"pikachu": return "⚡"
		"charmander": return "🔥"
		"bulbasaur": return "🌿"
		"squirtle": return "💧"
		_: return "🔴"
