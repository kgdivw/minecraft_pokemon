extends Control

@onready var crosshair = $Crosshair
@onready var pokemon_count = $PokemonCount
@onready var catch_message = $CatchMessage

var message_timer: float = 0.0

func _ready() -> void:
	update_pokemon_count()
	catch_message.visible = false

func _process(delta: float) -> void:
	if message_timer > 0:
		message_timer -= delta
		if message_timer <= 0:
			catch_message.visible = false

func update_pokemon_count() -> void:
	var count = GameData.caught_pokemon.size()
	pokemon_count.text = "Gevangen: " + str(count)

func show_catch_message(pokemon_name: String) -> void:
	catch_message.text = pokemon_name + " gevangen!"
	catch_message.visible = true
	message_timer = 2.0
	update_pokemon_count()
