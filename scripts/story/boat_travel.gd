extends Node2D
class_name BoatTravel

# This script manages the boat traveling, satiety exhaustion, encounters, and port docking.

signal encounter_triggered(encounter_data)
signal port_docked(port_data)
signal satiety_changed(new_value)

var crew_satiety: int = 100
var dock_ports: Array = []
var encounter_chance: float = 0.05 # %chance

@export var dayLength = 1.5 # seconds
var dayTimer := Timer.new()
@export var encounterSpeed = 0.75
var encounterTimer := Timer.new()

@onready var boat: BoatChar = $BoatChar

var boat_position_index: int = 0
var traveled_path: Array = []

var boatMoving = false;

# FIX, Day currently resets if switch scenes to an encounter. 
func _ready():
	Utils.dockSelected.connect(_setTargetPos)
	set_process(true)

	dayTimer.wait_time = dayLength
	dayTimer.connect("timeout", _dayEnd)
	add_child(dayTimer)

	encounterTimer.wait_time = encounterSpeed
	encounterTimer.connect("timeout", check_for_encounter)
	add_child(encounterTimer)

	boat.position = CrewStatus.boatPosition
	_setTargetPos(CrewStatus.targetPosition)

func _process(delta):
	if boatMoving:
		updateTraveledPos(boat.position)


func exhaust_satiety():
	crew_satiety = max(0, crew_satiety - randi_range(3, 8))
	emit_signal("satiety_changed", crew_satiety)

func check_for_encounter():
	var chance = Utils.RNG.randf()
	if Utils.RNG.randf() < encounter_chance:
		_triggerEncounter()

func _draw():
	if traveled_path.size() > 2:
		for i in range(traveled_path.size() - 1):
			_draw_hashed_line(traveled_path[i], traveled_path[i + 1], Color(0.4, 0.7, 1.0), 12, 24, 24)

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


func _setTargetPos(val: Vector2):
	if val == Vector2(0, 0): return
	
	boat.setTargetPos(val)

	setTimers(true)
	CrewStatus.targetPosition = val

func updateTraveledPos(val: Vector2):
	traveled_path[traveled_path.size() - 1] = val
	queue_redraw()

func _on_boat_char_next_position(val: Vector2) -> void:
	traveled_path.append(val)
	queue_redraw()

func _on_boat_char_moving(val: bool) -> void:
	boatMoving = val
	if !val:
		setTimers(false)
		if boat: CrewStatus.boatPosition = boat.position

func _dayEnd():
	boat.isMoving = false
	setTimers(false)
	SceneLoader.goto_scene(Utils.KITCHEN_PATH)

func _triggerEncounter():
	boat.isMoving = false
	setTimers(false)
	
	SceneLoader.goto_scene(Utils.ENCOUNTER_PATH)

func setTimers(val: bool):
	if val:
		dayTimer.start()
		encounterTimer.start()
	else:
		dayTimer.stop()
		encounterTimer.stop()
