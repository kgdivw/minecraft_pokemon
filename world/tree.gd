extends Node3D

@export var health: int = 3
@export var wood_drop_count: int = 3

var is_being_chopped: bool = false

func take_damage() -> void:
	health -= 1

	# Schud animatie
	var tween = create_tween()
	tween.tween_property(self, "rotation:z", 0.1, 0.05)
	tween.tween_property(self, "rotation:z", -0.1, 0.1)
	tween.tween_property(self, "rotation:z", 0.0, 0.05)

	if health <= 0:
		chop_down()

func chop_down() -> void:
	# Drop hout
	for i in range(wood_drop_count):
		GameData.add_item("wood", 1)

	# Val animatie
	var tween = create_tween()
	tween.tween_property(self, "rotation:x", -1.5, 0.5)
	tween.tween_property(self, "scale", Vector3.ZERO, 0.3)
	tween.tween_callback(queue_free)
