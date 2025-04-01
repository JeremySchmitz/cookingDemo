class_name Bowl
extends Node2D

@export var area: Area2D

var nutrition = 0;
var poison = 0;

func _ready() -> void:
	area.area_entered.connect(_on_food_entered)
	area.area_exited.connect(_on_food_exit)
	
func _on_food_entered(area: Area2D) -> void:
	if area is DraggableArea and area.get_parent() is Food:
		poison += (area.get_parent() as Food).poison
		nutrition += (area.get_parent() as Food).nutrition
	
func _on_food_exit(area: Area2D) -> void:
	if area is DraggableArea and area.get_parent() is Food:
		poison -= (area.get_parent() as Food).poison
		nutrition -= (area.get_parent() as Food).nutrition
