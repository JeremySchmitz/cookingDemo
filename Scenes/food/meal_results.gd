extends Node2D

class_name MealResults

const MEAL_SUMMARY_SCENE = preload("res://Scenes/food/meal_summary.tscn")
var crewBefore: Array[Crew] = []
var crewAfter: Array[Crew] = []



func buildResults():
	for i in range(0, crewBefore.size()):
		var summary = _buildSummary(crewBefore[i], crewAfter[i])
		summary.position.y += 150 * i

func _buildSummary(before: Crew, after: Crew) -> MealSummary:
	var summary = MEAL_SUMMARY_SCENE.instantiate()
	summary.crewName = after.name
	summary.setHealth(before.health, after.health)
	summary.setHunger(before.health, after.health)
	$summarySpawn.add_child(summary)
	return summary
