extends Node2D
class_name Kitchen


const BOWL_SCENE = preload("res://Scenes/food/bowl.tscn")
const RESULTS_SCENE = preload("res://Scenes/food/results.tscn")

@export var cameraMoveWait = .2;

@onready var crew := CrewStatus.crew


func _ready() -> void:
	for i in range(0, crew.size()):
		_buildBowl(i)

func _buildBowl(i: int):
	var scene: Bowl = BOWL_SCENE.instantiate()
	scene.setNameTag(crew[i].name, crew[i].role)
	$Bowls.add_child(scene)
	scene.scale *= 2
	scene.position = Vector2(
		get_viewport_rect().size.x + 200 + (300 * i),
		 200)
	
func _on_dinner_bell_btn_pressed() -> void:
	var crewBefore = CrewStatus.crew
	var bowls = $Bowls.get_children()

	for bowl: Bowl in bowls:
		var i = crew.find_custom(func(x): return x.name == bowl.getName())
		var member = crew[i]
		if member:
			(member as Crew).eat(bowl.nutrition, bowl.poison)
		else: printerr("Could Not Find Crew Member: %s", name)
		
	var resultsAttrs: Array[GlobalEnums.CrewAttrs] = [
		GlobalEnums.CrewAttrs.HEALTH,
		GlobalEnums.CrewAttrs.HUNGER
		]
	SceneLoader.gotoResults(crewBefore, crew, resultsAttrs)
	
func buildResultsScn(crewBefore: Array[Crew], crewAfter: Array[Crew]):
	var results = RESULTS_SCENE.instantiate()
	results.crewBefore = crewBefore
	results.crewAfter = crew
	var resultsAttrs: Array[GlobalEnums.CrewAttrs] = [GlobalEnums.CrewAttrs.HEALTH, GlobalEnums.CrewAttrs.HUNGER]
	results.buildResults(resultsAttrs)
	results.nextScene = "encounter"

	return results
