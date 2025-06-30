extends Node2D
enum Mode {CHOP, SLICE, GRAB}

const BOWL_SCENE = preload("res://Scenes/food/bowl.tscn")
const RESULTS_SCENE = preload("res://Scenes/food/meal_results.tscn")

@export var cameraMoveWait = .2;

var curMode = Mode.CHOP
@onready var crew:= CrewStatus.crew
var crewDict: Dictionary = {}

func _ready() -> void:
	_buildCrewDictionary()
	for i in range(0, crew.size()):
		_buildBowl(i)

func _buildBowl(i: int):
	var scene: Bowl = BOWL_SCENE.instantiate()
	scene.setNameTag(crew[i].name, crew[i].role)
	$Bowls.add_child(scene)
	scene.scale *= 2
	scene.position = Vector2(
		get_viewport_rect().size.x + 200 + (300 * i),
		 200 )
	


func _on_chop_btn_pressed() -> void:
	curMode = Mode.CHOP
	$chopBtn.disabled = true
	$sliceBtn.disabled = false
	$grabBtn.disabled = false
	Utils.modeChange.emit(curMode)
	get_tree().get_root().set_input_as_handled()

func _on_grab_btn_pressed() -> void:
	curMode = Mode.GRAB
	$chopBtn.disabled = false
	$sliceBtn.disabled = false
	$grabBtn.disabled = true
	Utils.modeChange.emit(curMode)
	get_tree().get_root().set_input_as_handled()

func _on_slice_btn_pressed() -> void:
	curMode = Mode.SLICE
	$chopBtn.disabled = false
	$sliceBtn.disabled = true
	$grabBtn.disabled = false
	Utils.modeChange.emit(curMode)
	get_tree().get_root().set_input_as_handled()


func _on_dinner_bell_btn_pressed() -> void:
	print('bell rang!')
	var crewBefore = crew.duplicate(true)
	var bowls = $Bowls.get_children()
	
	for bowl: Bowl in bowls:
		var member = crewDict[bowl.getName()]
		if member:
			(member as Crew).eat(bowl.nutrition, bowl.poison)
		else: printerr("Could Not Find Crew Member: %s", name)
		
	var results = RESULTS_SCENE.instantiate()
	results.crewBefore = crewBefore
	results.crewAfter = crew
	results.buildResults()
	add_child(results)
	

func _buildCrewDictionary():
	var dict: Dictionary = {}
	for i in range(0, crew.size()):
		dict[crew[i].name] = crew[i]
	crewDict = dict
