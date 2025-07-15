extends Node2D

class_name CrewSummary

const labelSettings = preload("res://resources/LabelSettings/mealSummary_label_settings.tres")

@export var paddingTop: float
@export var paddingLeft: float
@export var labelHeight: float
@export var titleWidth: float
@export var resultsWidth: float

@onready var spawn: Node2D = $LabelSpawn

var crewName: String = "":
	set(val):
		crewName = val
		$Name.text = val

var beforeAttrs = {
	GlobalEnums.CrewAttrs.HEALTH: 0,
	GlobalEnums.CrewAttrs.CONSTITUTION: 0,
	GlobalEnums.CrewAttrs.SATIETY: 0,
	GlobalEnums.CrewAttrs.STRENGTH: 0,
	GlobalEnums.CrewAttrs.FISHING: 0,
	GlobalEnums.CrewAttrs.SANITY: 0
}

var afterAttrs = {
	GlobalEnums.CrewAttrs.HEALTH: 0,
	GlobalEnums.CrewAttrs.CONSTITUTION: 0,
	GlobalEnums.CrewAttrs.SATIETY: 0,
	GlobalEnums.CrewAttrs.STRENGTH: 0,
	GlobalEnums.CrewAttrs.FISHING: 0,
	GlobalEnums.CrewAttrs.SANITY: 0
}

var healthBefore: int
var healthAfter: int

var hungerBefore: int
var hungerAfter: int

var constitutionBefore: float
var constitutionAfter: float

var satietyBefore: int
var satietyAfter: int

var strengthBefore: int
var strengthAfter: int

var fishingBefore: int
var fishingAfter: int

var sanityBefore: float
var sanityAfter: float

func setAttr(attr: GlobalEnums.CrewAttrs, before: int, after: int):
	beforeAttrs[attr] = before
	afterAttrs[attr] = after


# func setHealth(before: int, after: int):
# 	healthBefore = before
# 	healthAfter = after
# 	$HealthResults.text = "%s -> %s" % [healthBefore, healthAfter]

# func setHunger(before: int, after: int):
# 	hungerBefore = before
# 	hungerAfter = after
# 	$HungerResults.text = "%s -> %s" % [hungerBefore, hungerAfter]
	
	
func buildSummary(attrs: Array):
	for i in range(0, attrs.size()):
		var attr = attrs[i]
		var label = buildAttr(attr, beforeAttrs[attr], afterAttrs[attr])
		$LabelSpawn.add_child(label)
		label.position.y += paddingTop * i

func buildAttr(attr: GlobalEnums.CrewAttrs, before: int, after: int) -> Label:
	var title = Label.new()
	var results = Label.new()

	title.text = GlobalEnums.CrewAttrs.find_key(attr)
	results.text = "%s -> %s" % [before, after]
	title.label_settings = labelSettings
	results.label_settings = labelSettings

	title.add_child(results)

	# title.set_deferred(
	title.set_size(Vector2(titleWidth, labelHeight))
	results.set_size(Vector2(resultsWidth, labelHeight))

	results.position.x = titleWidth + paddingLeft

	return title
