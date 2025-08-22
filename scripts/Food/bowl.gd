class_name Bowl
extends Control

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
	
# TODO Parent Food to bowl on drop
func _on_food_entered(node: Area2D) -> void:
	if node is DraggableArea && is_instance_of(node.get_parent(), Food):
		_update(node, false)
		node.reparentOnDrop(%FoodParent)
	
func _on_food_exit(node: Area2D) -> void:
	if node is DraggableArea && is_instance_of(node.get_parent(), Food):
		_update(node, true)
		node.reparentOnDrop()
		
func _update(node: Area2D, subtract = false):
	var poisonNode: Poison = _getSibling(Poison, node)
	if poisonNode:
		_updatePoison(poisonNode, subtract)

	var nutritionNode: Nutrition = _getSibling(Nutrition, node)
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
	
func setNameTag(tagName: String, role: GlobalEnums.Role):
	crewName = tagName
	$Namecard.text = "{0} ({1})".format([tagName, GlobalEnums.Role.keys()[role]])
	
func getName() -> String:
	return crewName
