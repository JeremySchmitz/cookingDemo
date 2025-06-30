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

func _ready() -> void:
	area.area_entered.connect(_on_food_entered)
	area.area_exited.connect(_on_food_exit)
	nutrition = 0
	poison = 0
	
func _on_food_entered(area: Area2D) -> void:
	if area is DraggableArea and area.get_parent() is Food:
		_updatePoison(area.get_parent(), false)
		_updateNutrition(area.get_parent(), false)
	
func _on_food_exit(area: Area2D) -> void:
	if area is DraggableArea and area.get_parent() is Food:
		_updatePoison(area.get_parent(), true)
		_updateNutrition(area.get_parent(), true)
		
		
func _updatePoison(parent: Food, subtract = false):
	var poisonChild = _getChild(Poison, parent)
	if poisonChild:
		if subtract: poison = poison - poisonChild.poison
		else: poison = poison + poisonChild.poison

func _updateNutrition(parent: Food, subtract = false):
	var nutritionChild = _getChild(Nutrition, parent)
	if nutritionChild:
		if subtract: nutrition = nutrition - nutritionChild.nutrition
		else: nutrition = nutrition + nutritionChild.nutrition

func _getChild(className: Variant, parent: Node = self) -> Poison:
	for child in parent.get_children():
		if is_instance_of(child, className):
			return child
	return null
	
func setNameTag(val: String):
	$Namecard.text = val
	
