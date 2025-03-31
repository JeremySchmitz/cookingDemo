class_name Organ
extends Food

@onready var polygon: PackedVector2Array = collisionPoly.polygon

var parented = true;


func _on_draggable_area_dragging() -> void:
	if !parented:
		return
	print('reparent')
	print('newParent: ', get_parent().get_parent().get_parent())
#	TODO This needs to be made more surefire 
	reparent(get_parent().get_parent().get_parent())
	parented = false
	pass # Replace with function body.

func _on_health_cooked_changed(diff: int) -> void:
	print('cookedChanged')
	if cookedBurnt:
		polygon2D.color.r = max(polygon2D.color.r - (diff * .005), .4)
		polygon2D.color.g = min(polygon2D.color.g + (diff * .01), 1)
	else: 
		polygon2D.color.g = max(polygon2D.color.g - (diff * .01), .4)
		polygon2D.color.b = max(polygon2D.color.b - (diff * .01), .4)
