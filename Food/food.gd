class_name Food
extends Node2D

@export var polygon2D: Polygon2D
@export var collisionPoly: CollisionPolygon2D
@export var choppable: Choppable
var scene = preload("res://Scenes/food.tscn")

var draggable = false

func _ready():
	Signals.modeChange.connect(_on_mode_change)

func _on_choppable_chopped(poly1: PackedVector2Array, poly2: PackedVector2Array) -> void:
	if !poly1.size():
		return
		
	var food:= await scene.instantiate()
	updateSibling.call_deferred(food, poly2, poly1)


func updateSibling(sibling: Food, poly: PackedVector2Array, chopPoly: PackedVector2Array):
	print('addSibling')
	sibling.position = position
	#sibling.polygon2D.polygon = polygon
	sibling.collisionPoly.polygon = poly
	sibling.choppable.addChops(chopPoly)
	add_sibling(sibling)


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

func _duplicate() -> Food:
	var newFood = duplicate()
	print('polygon2D' + str(polygon2D))
	newFood.polygon2D = polygon2D.duplicate()
	newFood.collisionPoly = collisionPoly.duplicate()
	
	return newFood
