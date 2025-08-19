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


# FIX, Day currently resets if switch scenes to an encounter. 
func _ready():
	SignalBus.canDock.connect(_on_can_dock)
	# TODO run simple day timer
	$Camera2D.limitRight = $Camera2D.get_window().size.x - $world_gen.width
	$Camera2D.limitDown = $Camera2D.get_window().size.y - $world_gen.height

	set_process(true)

	dayTimer.wait_time = dayLength
	dayTimer.connect("timeout", _dayEnd)
	add_child(dayTimer)

	encounterTimer.wait_time = encounterSpeed
	encounterTimer.connect("timeout", check_for_encounter)
	add_child(encounterTimer)

	_setBoatPosition()

	var timer = Timer.new()
	timer.wait_time = 0.1
	timer.one_shot = true
	add_child(timer)
	timer.start()

func workCrew(low: float, high: float):
	CrewStatus.workCrew(low, high)

func check_for_encounter():
	var chance = Utils.RNG.randf()
	if Utils.RNG.randf() < encounter_chance:
		_triggerEncounter()


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

func _setBoatPosition():
	var pos: Vector2
	if CrewStatus.boatPosition != Vector2(0, 0):
		pos = CrewStatus.boatPosition
	else:
		var ports = $world_gen.portPositions
		pos = ports[0]

	boat.position = pos

func _on_can_dock(canDock: bool):
	if has_node("CanvasLayer/Control/DockButton"):
		$CanvasLayer/Control/DockButton.visible = canDock

func _on_dock_button_pressed() -> void:
	CrewStatus.boatPosition = boat.position
	SceneLoader.goto_scene(Utils.STORE_PATH)
