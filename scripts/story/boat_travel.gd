extends Node2D


signal encounter_triggered(encounter_data)
signal port_docked(port_data)
signal satiety_changed(new_value)

var crew_satiety: int = 100
var path_points: Array = []
var dock_ports: Array = []
var encounter_chance: float = 0.15 # 15% chance per segment
var port_dock_chance: float = 0.08 # 8% chance per segment

var boat_position_index: int = 0
var traveled_path: Array = []
var traveling = false

@onready var boat_sprite: Sprite2D = $BoatSprite

func _ready():
	if path_points.size() < 2:
		push_error("Path must have at least two points.")
		return
	boat_sprite.position = path_points[0]
	traveled_path.append(path_points[0])
	set_process(true)

func _process(delta):
	if boat_position_index < path_points.size() - 1:
		move_boat_along_path(delta)
	else:
		set_process(false)

func move_boat_along_path(delta):
	var current_pos = boat_sprite.position
	var target_pos = path_points[boat_position_index + 1]
	var direction = (target_pos - current_pos).normalized()
	var speed = 120.0 # pixels per second
	var step = direction * speed * delta

	if current_pos.distance_to(target_pos) < step.length():
		boat_sprite.position = target_pos
		boat_position_index += 1
		traveled_path.append(target_pos)
		exhaust_satiety()
		check_for_encounter()
		check_for_port()
	else:
		boat_sprite.position += step

	queue_redraw()
	

func exhaust_satiety():
	crew_satiety = max(0, crew_satiety - Utils.RNG.randi_range(3, 8))
	emit_signal("satiety_changed", crew_satiety)

func check_for_encounter():
	if Utils.RNG.randf() < encounter_chance:
		var encounter_data = {"type": "sea_monster", "difficulty": Utils.RNGrandi_range(1, 5)}
		emit_signal("encounter_triggered", encounter_data)

func check_for_port():
	if Utils.RNG.randf() < port_dock_chance:
		var port = dock_ports[Utils.RNG.randi() % dock_ports.size()]
		var port_data = {"name": port, "event": "new_supplies"}
		emit_signal("port_docked", port_data)

func _draw():
	var path = traveled_path.duplicate()
	path.append(boat_sprite.position)
	for i in range(path.size() - 1):
		_draw_hashed_line(path[i], path[i + 1], Color(0.4, 0.7, 1.0), 12, 48, 24)


func _draw_hashed_line(from_pos, to_pos, color, width, dash_length, gap_length):
	var total_length = from_pos.distance_to(to_pos)
	var direction = (to_pos - from_pos).normalized()
	var drawn = 0.0
	var p = from_pos
	while drawn < total_length:
		var next_dash = min(dash_length, total_length - drawn)
		var dash_end = p + direction * next_dash
		draw_line(p, dash_end, color, width)
		drawn += next_dash + gap_length
		p = dash_end + direction * gap_length

func start_boat_travel(path_array: Array, ports_array: Array):
	path_points = path_array
	dock_ports = ports_array
	boat_position_index = 0
	traveled_path.clear()
	boat_sprite.position = path_points[0]
	traveled_path.append(path_points[0])
	traveling = true
	set_process(true)
