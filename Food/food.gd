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


func updateOrgans():
	var organs:= get_node("Organs").get_children() 
	var vOrgans:= get_node("VisibleOrgans").get_children() 
	
	var globalPoly = _getGlobalPoly()
	
	for organ in organs:
		if organ is not Organ: break
		var organCenter = _getGobalCenter(organ.global_position, organ.polygon)
		if !Geometry2D.is_point_in_polygon(organCenter, globalPoly):
			organ.queue_free()
		
	for organ in vOrgans:
		if organ is not Organ: break
		var organCenter = _getGobalCenter(organ.global_position, organ.polygon)
		if !Geometry2D.is_point_in_polygon(organCenter, globalPoly):
			organ.queue_free()
	
	
func _getGobalCenter(globalPos:Vector2, points: PackedVector2Array) -> Vector2:
	var avg = Vector2(0,0)
	for p in points:
		avg += p
	avg /= points.size()
	
	return globalPos - avg
	
	
func _getGlobalPoly() -> PackedVector2Array:
	var newPoly = []
	for p in collisionPoly.polygon:
		newPoly.append(global_position + p)
	return newPoly
	
