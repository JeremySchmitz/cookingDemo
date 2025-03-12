class_name Food
extends Node2D

@export var polygon2D: Polygon2D
@export var collisionPoly: CollisionPolygon2D
var scene = preload("res://Scenes/food.tscn")



func _on_choppable_chopped(polygon: PackedVector2Array) -> void:
	var newFood: Food = scene.instantiate()
	newFood.ready.connect(updateSibling.bind(newFood, polygon))
	
func updateSibling(sibling: Food, polygon: PackedVector2Array):
	sibling.position = position
	sibling.polygon2D.polygon = polygon
	sibling.collisionPoly.polygon = polygon
	add_sibling(sibling)
	
