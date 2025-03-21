class_name Food
extends Node2D

@export var polygon2D: Polygon2D
@export var collisionPoly: CollisionPolygon2D

var draggable = false

func _ready():
	Signals.modeChange.connect(_on_mode_change)


func _on_sliceable_sliced(line: PackedVector2Array) -> void:
	var organs = get_node("Organs").get_children()
	var visibleParent = get_node("VisibleOrgans")
	for organ: Organ in organs:
		var intersections = Geometry2D.intersect_polygons(setGlobal(organ), line)
		if intersections.size():
			organ.reparent(visibleParent)


func setGlobal(organ: Organ):
	var newLine = []
	var p = organ.position
	for point in organ.polygon:
		newLine.append(Vector2(point.x + p.x, point.y + p.y))
	return newLine
		

func _on_draggable_area_area_exited(area: Area2D) -> void:
	var parent = area.get_parent()
	if draggable and parent is Organ:
		parent.reparent.call_deferred(get_parent())
		
func _on_mode_change(m: GlobalEnums.Mode):
	match m:
		GlobalEnums.Mode.GRAB:
			draggable = true
		_:
			draggable = false
