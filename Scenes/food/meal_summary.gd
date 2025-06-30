extends Node2D

class_name MealSummary

var crewName: String = "" :
	set(val):
		crewName = val
		$Name.text = val
var healthBefore: int
var healthAfter: int
var hungerBefore: int
var hungerAfter: int


func setHealth(before: int, after: int):
	healthBefore = before
	healthAfter = after
	$HealthResults.text = "%s -> %s" % [healthBefore, healthAfter]

func setHunger(before: int, after: int):
	hungerBefore = before
	hungerAfter = after
	$HungerResults.text = "%s -> %s" % [hungerBefore, hungerAfter]
