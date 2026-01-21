extends Node

var selected_character: String = "boy1"

var caught_pokemon: Array[String] = []

var available_pokemon = [
	{"name": "Pikachu", "scene": "res://pikachu.tscn"},
	{"name": "Charmander", "scene": "res://charmander.tscn"},
	{"name": "Bulbasaur", "scene": "res://bulbasaur.tscn"},
	{"name": "Squirtle", "scene": "res://squirtle.tscn"},
]

func catch_pokemon(pokemon_name: String) -> void:
	if pokemon_name not in caught_pokemon:
		caught_pokemon.append(pokemon_name)
		print("Gevangen: " + pokemon_name + "!")

func has_pokemon(pokemon_name: String) -> bool:
	return pokemon_name in caught_pokemon

func get_random_caught_pokemon() -> Dictionary:
	if caught_pokemon.size() == 0:
		return {}
	var random_name = caught_pokemon[randi() % caught_pokemon.size()]
	for p in available_pokemon:
		if p["name"] == random_name:
			return p
	return {}
