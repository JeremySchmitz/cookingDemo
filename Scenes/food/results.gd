extends Node2D
class_name Results

var nextScene: String = ""

const CREW_SUMMARY_SCENE = preload("res://Scenes/food/crew_summary.tscn")

var crewBefore: Array[Crew] = []
var crewAfter: Array[Crew] = []


func buildResults(attrs: Array[GlobalEnums.CrewAttrs]):
	for i in range(0, crewBefore.size()):
		var summary = _buildSummary(crewBefore[i], crewAfter[i], attrs)
		summary.position.y += 150 * i

func _buildSummary(before: Crew, after: Crew, attrs: Array[GlobalEnums.CrewAttrs]) -> CrewSummary:
	var summary = CREW_SUMMARY_SCENE.instantiate()
	$summarySpawn.add_child(summary)
	summary.crewName = after.name

	for attr in attrs:
		var beforeAttr
		var afterAttr
		match attr:
			GlobalEnums.CrewAttrs.HEALTH:
				beforeAttr = before.health
				afterAttr = after.health
			GlobalEnums.CrewAttrs.CONSTITUTION:
				beforeAttr = before.constitution
				afterAttr = after.constitution
			GlobalEnums.CrewAttrs.STRENGTH:
				beforeAttr = before.strength
				afterAttr = after.strength
			GlobalEnums.CrewAttrs.FISHING:
				beforeAttr = before.fishing
				afterAttr = after.fishing
			GlobalEnums.CrewAttrs.SANITY:
				beforeAttr = before.sanity
				afterAttr = after.sanity
			GlobalEnums.CrewAttrs.HUNGER:
				beforeAttr = before.satiety * 100
				afterAttr = after.satiety * 100
		summary.setAttr(attr, beforeAttr, afterAttr)

	summary.buildSummary(attrs)
	return summary


func _on_cont_btn_pressed() -> void:
	match nextScene:
		"kitchen":
			_loadKitchen()
		"encounter":
			_loadEncounter()

func _loadKitchen():
	var kitchenScn := load(Utils.KITCHEN_PATH)

	var prepInstance = kitchenScn.instantiate()
	Utils.switchScene.emit(prepInstance)

func _loadEncounter():
	var encounterScn := load(Utils.ENCOUNTER_PATH)
	var prepInstance = encounterScn.instantiate()
	Utils.switchScene.emit(prepInstance)
