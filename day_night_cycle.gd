extends Node3D

@export var day_length_seconds: float = 120.0

var time_of_day: float = 0.5  # Start op middag (12:00)
var is_night: bool = false

var sun_light: DirectionalLight3D
var ambient_light: DirectionalLight3D

signal day_started()
signal night_started()

func _ready() -> void:
	add_to_group("day_night")
	find_lights()
	apply_lighting()

func find_lights() -> void:
	sun_light = get_parent().get_node_or_null("DirectionalLight3D")
	ambient_light = get_parent().get_node_or_null("AmbientLight")

func _process(delta: float) -> void:
	# Update tijd
	time_of_day += delta / day_length_seconds
	if time_of_day >= 1.0:
		time_of_day -= 1.0

	check_day_night_transition()
	apply_lighting()

func check_day_night_transition() -> void:
	var was_night = is_night

	# Simpele logica:
	# 0.0 = middernacht (00:00)
	# 0.25 = ochtend (06:00) - zon komt op
	# 0.5 = middag (12:00) - volle zon
	# 0.75 = avond (18:00) - zon gaat onder
	# 1.0 = middernacht (00:00)

	is_night = time_of_day < 0.25 or time_of_day >= 0.75

	if is_night and not was_night:
		night_started.emit()
		print("Het wordt nacht... Pas op voor zombies!")
	elif not is_night and was_night:
		day_started.emit()
		print("De zon komt op!")

func apply_lighting() -> void:
	if not sun_light:
		find_lights()
		if not sun_light:
			return

	if is_night:
		# NACHT: Donker blauw licht, zwak
		sun_light.light_energy = 0.1
		sun_light.light_color = Color(0.3, 0.35, 0.5)
		sun_light.rotation_degrees.x = -30

		if ambient_light:
			ambient_light.light_energy = 0.05
			ambient_light.light_color = Color(0.2, 0.2, 0.4)
	else:
		# DAG: Helder wit/geel licht, sterk
		# Bereken zon positie (hoogste punt om 12:00 = time 0.5)
		var day_progress = (time_of_day - 0.25) / 0.5  # 0 bij 06:00, 1 bij 18:00
		var sun_angle = -20 + day_progress * -140  # -20 tot -160 graden

		sun_light.rotation_degrees.x = sun_angle
		sun_light.light_energy = 1.5
		sun_light.light_color = Color(1.0, 0.95, 0.9)

		if ambient_light:
			ambient_light.light_energy = 0.4
			ambient_light.light_color = Color(0.8, 0.85, 1.0)

func get_time_string() -> String:
	var hours = int(time_of_day * 24)
	var minutes = int((time_of_day * 24 - hours) * 60)
	return "%02d:%02d" % [hours, minutes]

func is_daytime() -> bool:
	return not is_night
