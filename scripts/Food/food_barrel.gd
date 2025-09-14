extends Control
class_name FoodBarrel

@onready var foodNode: Control = %BarrelFoodNode
var foodName: String
var foodScene: PackedScene

func initialize(scene: PackedScene, name: String, count: int):
	foodScene = scene
	foodName = name
	for i in range(count):
		_addFood()

func _addFood():
	var node: Food = foodScene.instantiate()
	foodNode.add_child(node)
	node.scale = Vector2(1, 1)
	node.position = size / 2.0

func _on_area_2d_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	var parent = area.get_parent()
	if !parent.is_in_group('food'): return
	if parent.get_parent() != foodNode: return
	if !is_instance_of(area, DraggableArea): return


func getCount():
	return foodNode.get_child_count()
