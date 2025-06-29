class_name Organ
extends Food

@onready var polygon: PackedVector2Array = collisionPoly.polygon

var parented = true;

func _on_draggable_area_dragging() -> void:
	if !parented:
		return
#	TODO This needs to be made more surefire 
	reparent(get_parent().get_parent().get_parent())
	parented = false
