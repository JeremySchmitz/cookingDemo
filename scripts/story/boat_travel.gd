extends Node2D
class_name BoatTravel

var crew_satiety: int = 100
var dock_ports: Array = []
var encounter_chance: float = 0.05 # %chance

@export var dayLength = 1.5 # seconds
var dayTimer := Timer.new()
@export var encounterSpeed = 0.75
var encounterTimer := Timer.new()

@onready var boat: BoatChar = $BoatChar
@onready var ports: Array[Node] = $Ports.get_children()

var boat_position_index: int = 0
var traveled_path: Array = []

var boatMoving = false

# FIX, Day currently resets if switch scenes to an encounter. 
func _ready():
	SignalBus.portSelected.connect(_setTargetPos)
	set_process(true)

	dayTimer.wait_time = dayLength
	dayTimer.connect("timeout", _dayEnd)
	add_child(dayTimer)

	encounterTimer.wait_time = encounterSpeed
	encounterTimer.connect("timeout", check_for_encounter)
	add_child(encounterTimer)

	boat.position = CrewStatus.boatPosition
	_setTargetPos(CrewStatus.targetPosition)

	var timer = Timer.new()
	timer.wait_time = 0.1
	timer.one_shot = true
	timer.connect("timeout", updatePortDistances)
	add_child(timer)
	timer.start()

func _process(delta):
	if boatMoving:
		updateTraveledPos(boat.position)


func workCrew(low: float, high: float):
	CrewStatus.workCrew(low, high)

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
		call_deferred("updatePortDistances")

func _dayEnd():
	boat.isMoving = false
	setTimers(false)
	# todo base on distance traveled
	workCrew(10, 25)
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

func updatePortDistances():
	var map = $NavigationRegion2D.get_navigation_map()
	# TODO this doesnt find the exact same path as the navigation agent. Find a better way
	for port: Port in ports:
		var path = NavigationServer2D.map_get_path(map, boat.global_position, port.global_position, false)
		var distance = 0
		for i in range(0, path.size() - 1):
			distance += path[i].distance_to(path[i + 1])
		distance = ceil(distance / boat.speed)
		port.distance = distance
