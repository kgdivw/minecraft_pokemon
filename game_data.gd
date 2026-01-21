extends Node

var selected_character: String = "boy1"

var caught_pokemon: Array[String] = []

var available_pokemon = [
	{"name": "Pikachu", "scene": "res://pikachu.tscn"},
	{"name": "Charmander", "scene": "res://charmander.tscn"},
	{"name": "Bulbasaur", "scene": "res://bulbasaur.tscn"},
	{"name": "Squirtle", "scene": "res://squirtle.tscn"},
]

# Minecraft inventory
var inventory: Dictionary = {
	"wood": 0,
	"stone": 0,
	"dirt": 0,
	"coal": 0,
	"iron": 0,
	"diamond": 0,
	"beef": 0,
	"pork": 0,
	"wool": 0,
}

var selected_slot: int = 0
var hotbar_items: Array[String] = ["sword", "pickaxe", "axe", "shovel", "wood", "stone", "dirt", "beef", "wool"]

signal inventory_changed()
signal item_selected(item_name: String)

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

func add_item(item_name: String, count: int = 1) -> void:
	if inventory.has(item_name):
		inventory[item_name] += count
	else:
		inventory[item_name] = count
	inventory_changed.emit()
	print("+" + str(count) + " " + item_name + " (totaal: " + str(inventory[item_name]) + ")")

func remove_item(item_name: String, count: int = 1) -> bool:
	if inventory.has(item_name) and inventory[item_name] >= count:
		inventory[item_name] -= count
		inventory_changed.emit()
		return true
	return false

func get_item_count(item_name: String) -> int:
	if inventory.has(item_name):
		return inventory[item_name]
	return 0

func select_hotbar_slot(slot: int) -> void:
	selected_slot = clamp(slot, 0, hotbar_items.size() - 1)
	item_selected.emit(hotbar_items[selected_slot])

func get_selected_item() -> String:
	return hotbar_items[selected_slot]
