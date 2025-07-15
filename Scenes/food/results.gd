extends Node2D

class_name Results

const CREW_SUMMARY_SCENE = preload("res://Scenes/food/crew_summary.tscn")
var crewBefore: Array[Crew] = []
var crewAfter: Array[Crew] = []


func buildResults():
	for i in range(0, crewBefore.size()):
		var summary = _buildSummary(crewBefore[i], crewAfter[i])
		summary.position.y += 150 * i

func _buildSummary(before: Crew, after: Crew) -> CrewSummary:
	var summary = CREW_SUMMARY_SCENE.instantiate()
	$summarySpawn.add_child(summary)
	summary.crewName = after.name
	# summary.setHealth(before.health, after.health)
	# summary.setHunger(before.health, after.health)
	summary.setAttr(GlobalEnums.CrewAttrs.HEALTH, before.health, after.health)
	summary.setAttr(GlobalEnums.CrewAttrs.HUNGER, before.satiety * 100, after.satiety * 100)
	summary.buildSummary([GlobalEnums.CrewAttrs.HEALTH, GlobalEnums.CrewAttrs.HUNGER])
	return summary
