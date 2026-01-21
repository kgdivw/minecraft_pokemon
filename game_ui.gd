extends Control

@onready var pokemon_count = $PokemonCount
@onready var catch_message = $CatchMessage
@onready var hotbar = $Hotbar
@onready var time_label = $TimeLabel
@onready var health_bar = $HealthBar
@onready var hunger_bar = $HungerBar
@onready var mode_label = $ModeLabel

var message_timer: float = 0.0
var hotbar_slots: Array[Control] = []

func _ready() -> void:
	update_pokemon_count()
	catch_message.visible = false
	create_hotbar()
	create_health_bar()
	create_hunger_bar()
	GameData.inventory_changed.connect(_on_inventory_changed)
	GameData.item_selected.connect(_on_item_selected)
	update_hotbar_selection()

	# Connect player signals
	var player = get_parent().get_node_or_null("Player")
	if player:
		player.health_changed.connect(_on_health_changed)
		player.hunger_changed.connect(_on_hunger_changed)

func _process(delta: float) -> void:
	if message_timer > 0:
		message_timer -= delta
		if message_timer <= 0:
			catch_message.visible = false

	update_time_display()
	update_mode_display()

func update_time_display() -> void:
	var day_night = get_parent().get_node_or_null("DayNightCycle")
	if day_night and day_night.has_method("get_time_string"):
		var time_str = day_night.get_time_string()
		var period = "Dag" if day_night.is_daytime() else "Nacht"
		time_label.text = time_str + " (" + period + ")"

func update_mode_display() -> void:
	var player = get_parent().get_node_or_null("Player")
	if player:
		if player.is_creative_mode:
			mode_label.text = "CREATIVE" + (" - Vliegen" if player.is_flying else "")
		else:
			mode_label.text = "SURVIVAL"

func create_health_bar() -> void:
	# Maak hartjes voor health
	for i in range(10):
		var heart = Label.new()
		heart.name = "Heart" + str(i)
		heart.text = "❤"
		heart.add_theme_font_size_override("font_size", 20)
		heart.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
		heart.position = Vector2(i * 22, 0)
		health_bar.add_child(heart)

func create_hunger_bar() -> void:
	# Maak drumsticks voor hunger
	for i in range(10):
		var food = Label.new()
		food.name = "Food" + str(i)
		food.text = "🍖"
		food.add_theme_font_size_override("font_size", 18)
		food.position = Vector2(i * 22, 0)
		hunger_bar.add_child(food)

func _on_health_changed(current: int, maximum: int) -> void:
	var hearts = current / 2
	var half_heart = current % 2

	for i in range(10):
		var heart = health_bar.get_node_or_null("Heart" + str(i))
		if heart:
			if i < hearts:
				heart.text = "❤"
				heart.modulate = Color(1, 1, 1)
			elif i == hearts and half_heart > 0:
				heart.text = "❤"
				heart.modulate = Color(1, 1, 1, 0.5)
			else:
				heart.text = "♡"
				heart.modulate = Color(0.3, 0.3, 0.3)

func _on_hunger_changed(current: int, maximum: int) -> void:
	var drumsticks = current / 2
	var half_drumstick = current % 2

	for i in range(10):
		var food = hunger_bar.get_node_or_null("Food" + str(i))
		if food:
			if i < drumsticks:
				food.modulate = Color(1, 1, 1)
			elif i == drumsticks and half_drumstick > 0:
				food.modulate = Color(1, 1, 1, 0.5)
			else:
				food.modulate = Color(0.3, 0.3, 0.3)

func create_hotbar() -> void:
	var slot_size = 50
	var spacing = 5
	var total_slots = GameData.hotbar_items.size()
	var total_width = total_slots * slot_size + (total_slots - 1) * spacing

	hotbar.custom_minimum_size = Vector2(total_width, slot_size + 20)

	for i in range(total_slots):
		var slot = Panel.new()
		slot.custom_minimum_size = Vector2(slot_size, slot_size)
		slot.position = Vector2(i * (slot_size + spacing), 0)

		var label = Label.new()
		label.name = "ItemLabel"
		label.text = GameData.hotbar_items[i].substr(0, 3).to_upper()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.size = Vector2(slot_size, slot_size)
		slot.add_child(label)

		var num_label = Label.new()
		num_label.name = "NumLabel"
		num_label.text = str(i + 1)
		num_label.position = Vector2(2, 2)
		num_label.add_theme_font_size_override("font_size", 10)
		slot.add_child(num_label)

		hotbar.add_child(slot)
		hotbar_slots.append(slot)

func update_hotbar_selection() -> void:
	for i in range(hotbar_slots.size()):
		var slot = hotbar_slots[i]
		if i == GameData.selected_slot:
			slot.modulate = Color(1.2, 1.2, 0.8)
		else:
			slot.modulate = Color(1, 1, 1)

func _on_item_selected(_item_name: String) -> void:
	update_hotbar_selection()

func _on_inventory_changed() -> void:
	update_pokemon_count()

func update_pokemon_count() -> void:
	var count = GameData.caught_pokemon.size()
	var wood = GameData.get_item_count("wood")
	var beef = GameData.get_item_count("beef")
	pokemon_count.text = "Pokemon: " + str(count) + " | Hout: " + str(wood) + " | Vlees: " + str(beef)

func show_catch_message(pokemon_name: String) -> void:
	catch_message.text = pokemon_name + " gevangen!"
	catch_message.visible = true
	message_timer = 2.0
	update_pokemon_count()
