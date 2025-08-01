class_name Bowl
extends Node2D

@export var area: Area2D

var nutrition = 0:
	get:
		return nutrition
	set(val):
		$NutritionLabel.text = "Nutrition: " + str(val)
		nutrition = val
		
var poison = 0:
	get:
		return poison
	set(val):
		$PoisonLabel.text = "Poison: " + str(val)
		poison = val
		
var crewName: String

func _ready() -> void:
	area.area_entered.connect(_on_food_entered)
	area.area_exited.connect(_on_food_exit)
	nutrition = 0
	poison = 0
	
func _on_food_entered(area: Area2D) -> void:
	_update(area, false)

	
func _on_food_exit(area: Area2D) -> void:
	_update(area, true)
		
func _update(area: Area2D, subtract = false):
	var poisonNode: Poison = _getSibling(Poison, area)
	if poisonNode:
		_updatePoison(poisonNode, subtract)

	var nutritionNode: Nutrition = _getSibling(Nutrition, area)
	if nutritionNode:
		_updateNutrition(nutritionNode, subtract)

		
func _updatePoison(poisonNode: Poison, subtract = false):
	if subtract: poison = poison - poisonNode.poison
	else: poison = poison + poisonNode.poison

func _updateNutrition(nutritionNode: Nutrition, subtract = false):
	if subtract: nutrition = nutrition - nutritionNode.nutrition
	else: nutrition = nutrition + nutritionNode.nutrition

func _getSibling(className: Variant, node: Node2D):
	for child in node.get_parent().get_children():
		if is_instance_of(child, className):
			return child
	return null
	
func setNameTag(name: String, role: GlobalEnums.Role):
	crewName = name
	$Namecard.text = "{0} ({1})".format([name, GlobalEnums.Role.keys()[role]])
	
func getName() -> String:
	return crewName
