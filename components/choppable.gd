class_name Choppable
extends CanvasGroup

var g = Geometry2D

const maxFloatSize: float = 99999.0
const lineExpansion = 1
const sliceMaterial = preload("res://resources/subtract.material")

signal chopped(poly1:PackedVector2Array,poly2:PackedVector2Array)

@export var collisionArea: Area2D
@export var collisionNode: CollisionPolygon2D
@export var sliceGroup: CanvasGroup
@export var scenePath: String

var scene: PackedScene

var knifeEntered: Vector2
var knifeExited: Vector2


func _ready() -> void:
	scene = load(scenePath)
	collisionArea.area_entered.connect(_on_area_entered)
	collisionArea.area_exited.connect(_on_area_exited)


func _on_area_entered(body: Area2D):
	if body is KnifeChopper && body.monitoring && body.cutting:
		knifeEntered = body.position
	
func _on_area_exited(body: Area2D):
	if body is KnifeChopper && body.monitoring && body.cutting:
		knifeExited = body.position
		var line = _correctChopLine([knifeEntered, knifeExited])
		_chop(line, collisionNode.polygon)		


func _correctChopLine(line: PackedVector2Array):
#	Move points to relative position and make sure they sit on the borders of the shape
	return  _getLineOnShape(
			[_toRelativePositon(line[0]), _toRelativePositon(line[1])],
			 collisionNode.polygon)


func _toRelativePositon(p1: Vector2):
	var dist = global_position - position
	return p1 - dist


func _chop (line: PackedVector2Array, polygon: PackedVector2Array):
	var thiccLine = g.offset_polyline(line, lineExpansion)[0]
	var clip = g.clip_polygons(polygon, thiccLine)
	
	if clip.size() != 2:
		chopped.emit([], [])
		return
		
	var poly1 =g.offset_polygon(clip[0], lineExpansion)[0]
	var poly2 = g.offset_polygon(clip[1], lineExpansion)[0]
	collisionNode.set_deferred("polygon", poly1)
	
	addChops(poly2)
	_createCunk(poly1, poly2)
	chopped.emit(poly1, poly2)


func addChops(poly: PackedVector2Array):
	#TODO This is not the most efficient way to do this case
	#we are adding the same shape twice
	_addNew(poly, self)
	if sliceGroup:
		_addNew(poly, sliceGroup)

func _addNew(line: PackedVector2Array, group: CanvasGroup):
	var slice = Polygon2D.new()
	slice.polygon = line
	slice.clip_children = true
	slice.material = sliceMaterial
	group.add_child(slice)
	#DEBUG
	#slice.color = Color(0,1,0,1)
	
func _getLineOnShape(line: PackedVector2Array, polygon: PackedVector2Array):
	var updatedLine: PackedVector2Array = [Vector2(), Vector2()]

#	since the colidder has size we have to get the closest points to it
#	entering and exiting
	for i in range(0, line.size()):
		var smallestDist: float = maxFloatSize
		var p1: Vector2
		var p2: Vector2

		for j in range(0, polygon.size()):
			p1 = polygon[j]
			p2 = polygon[j + 1] if j + 1 < polygon.size() else polygon[0]
			
			var cp = g.get_closest_point_to_segment(line[i], p1, p2)
			var dist = abs(line[i].distance_to(cp))
			if(dist < smallestDist):
				smallestDist = dist
				updatedLine[i] = cp

	return updatedLine
	
func _createCunk(poly1: PackedVector2Array, poly2: PackedVector2Array) -> void:
	if !poly1.size():
		return
	
	var chunk: Node2D = await scene.instantiate()
	_updateChunk.call_deferred(chunk, poly2, poly1)
	
func _updateChunk(chunk: Node2D, poly: PackedVector2Array, chopPoly: PackedVector2Array):
	chunk.position = get_parent().position
	if "collisionPoly" in chunk:
		chunk.collisionPoly.polygon = poly
		
	for child in chunk.get_children():
		if child is Choppable:
			child.addChops(chopPoly)
			
	if "updateOrgans" in chunk:
		chunk.updateOrgans.call_deferred()
		
	get_parent().add_sibling(chunk)	
