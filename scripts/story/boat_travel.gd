extends Node2D
class_name BoatTravel

var crew_satiety: int = 100
var dock_ports: Array = []
var encounter_chance: float = .05 # %chance

@export var dayLength = 5 # seconds
@export var encounterSpeed = 0.75

@onready var boat: BoatChar = $BoatChar
@onready var clock: Clock = %Clock
@onready var encounterPanel: EncounterScene = %Encounter


# FIX, Day currently resets if switch scenes to an encounter. 
func _ready():
	SignalBus.canDock.connect(_on_can_dock)

	if World.tileSet:
		%world_gen._loadWorld()
	else:
		%world_gen._generate()

	$Camera2D.limitRight = $Camera2D.get_window().size.x - $world_gen.width
	$Camera2D.limitDown = $Camera2D.get_window().size.y - $world_gen.height

	%Inventory.inventory = CrewStatus.inventory

	_setBoatPosition()

	clock.encounterPeriod = encounterSpeed
	clock.duration = dayLength
	clock.start()

func _process(delta: float) -> void:
	boat.updateRange(clock.timeLeft)

func workCrew(low: float, high: float):
	CrewStatus.workCrew(low, high)

func check_for_encounter():
	if Utils.RNG.randf() < encounter_chance:
		_triggerEncounter()


func _dayEnd():
	boat.isMoving = false
	CrewStatus.boatPosition = boat.position
	# todo base on distance traveled
	workCrew(10, 25)
	SaveLoader.saveGame()
	SceneLoader.goto_scene(Utils.KITCHEN_PATH)

func _triggerEncounter():
	boat.isMoving = false
	CrewStatus.boatPosition = boat.position
	clock.pause()
	boat.disabled = true
	
	SaveLoader.saveGame()

	encounterPanel.loadEncounter()
	encounterPanel.show()

func _setBoatPosition():
	var pos: Vector2
	if CrewStatus.boatPosition != Vector2(0, 0):
		pos = CrewStatus.boatPosition
	else:
		var ports: Array = $world_gen.portPositions
		pos = ports[0]

	boat.position = pos

func _on_can_dock(canDock: bool):
	if has_node("CanvasLayer/Control/DockButton"):
		$CanvasLayer/Control/DockButton.visible = canDock

func _on_dock_button_pressed() -> void:
	CrewStatus.boatPosition = boat.position
	SceneLoader.goto_scene(Utils.STORE_PATH)

func _on_boat_char_moving(moving: bool) -> void:
	var timeScale = 1.0 if moving else 0.1
	clock.timeScale = timeScale

func _on_clock_done() -> void:
	_dayEnd()

func _on_clock_encounter_check() -> void:
	check_for_encounter()

func _on_results_hidden() -> void:
	boat.disabled = false
	clock.timeScale = 0.1
	clock.start()

func _on_inventory_btn_pressed() -> void:
	if %Inventory.visible: %Inventory.hide()
	else: %Inventory.show()
