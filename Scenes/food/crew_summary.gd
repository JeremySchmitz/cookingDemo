extends PanelContainer

class_name CrewSummary

const labelSettings = preload("res://resources/LabelSettings/mealSummary_label_settings.tres")

@export var paddingTop: float
@export var paddingLeft: float
@export var labelHeight: float
@export var titleWidth: float
@export var resultsWidth: float


var crewName: String = "":
	set(val):
		crewName = val
		%Name.text = val

var beforeAttrs = {
	GlobalEnums.CrewAttrs.HEALTH: 0,
	GlobalEnums.CrewAttrs.CONSTITUTION: 0,
	GlobalEnums.CrewAttrs.HUNGER: 0,
	GlobalEnums.CrewAttrs.STRENGTH: 0,
	GlobalEnums.CrewAttrs.FISHING: 0,
	GlobalEnums.CrewAttrs.SANITY: 0
}

var afterAttrs = {
	GlobalEnums.CrewAttrs.HEALTH: 0,
	GlobalEnums.CrewAttrs.CONSTITUTION: 0,
	GlobalEnums.CrewAttrs.HUNGER: 0,
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

func buildSummary(attrs: Array):
	for i in range(0, attrs.size()):
		var attr = attrs[i]
		var label = buildAttr(attr, beforeAttrs[attr], afterAttrs[attr])
		%LabelContainer.add_child(label)

func buildAttr(attr: GlobalEnums.CrewAttrs, before: int, after: int) -> HBoxContainer:
	var title := Label.new()
	var results := Label.new()
	var container := HBoxContainer.new()

	title.size_flags_horizontal = Control.SIZE_EXPAND

	title.text = GlobalEnums.CrewAttrs.find_key(attr)
	results.text = "%s -> %s" % [before, after]
	container.add_child(title)
	container.add_child(results)
	

	return container

func setBackgroundSize(count: int):
	var bg: Polygon2D = $Polygon2D
	var poly = bg.polygon

	var y = $LabelSpawn.position[0] + count * (paddingTop + labelHeight)
	poly[2].y = y
	poly[3].y = y
	bg.polygon = poly
