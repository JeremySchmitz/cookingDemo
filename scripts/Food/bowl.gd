class_name Bowl
extends Node2D

@export var area: Area2D

var nutrition = 0;
var poison = 0;

func _ready() -> void:
	area.area_entered.connect(_on_food_entered)
	area.area_exited.connect(_on_food_exit)
	setPoisonLabel(poison)
	setNutritionLabel(nutrition)
	
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
	setPoisonLabel(poison)

func _updateNutrition(parent: Food, subtract = false):
	var nutritionChild = _getChild(Nutrition, parent)
	if nutritionChild:
		if subtract: nutrition = nutrition - nutritionChild.nutrition
		else: nutrition = nutrition + nutritionChild.nutrition
	setNutritionLabel(nutrition)

func _getChild(className: Variant, parent: Node = self) -> Poison:
	for child in parent.get_children():
		if is_instance_of(child, className):
			return child
	return null
	
func setPoisonLabel(val: int):
	if($PoisonLabel):
		$PoisonLabel.text = "Poison: " + str(val)
	
func setNutritionLabel(val: int):
	if($NutritionLabel):
		$NutritionLabel.text = "Nutrion: " + str(val)
