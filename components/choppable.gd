class_name Choppable
extends Node2D

var g = Geometry2D

const maxFloatSize: float = 99999.0
const lineExpansion = 2

signal chopped(polygon:PackedVector2Array)

@export var scene: String
@export var foodShape: Polygon2D
@export var collisionArea: Area2D
@export var collisionNode: CollisionPolygon2D

var knifeEntered: Vector2
var knifeExited: Vector2


func _ready() -> void:
	collisionArea.area_entered.connect(_on_area_entered)
	collisionArea.area_exited.connect(_on_area_exited)


func _on_area_entered(body: Area2D):
	if body is KnifeChopper && body.monitoring && body.cutting:
		knifeEntered = body.position
	
func _on_area_exited(body: Area2D):
	print('on area exited. Is knighChopper: ' + str(body is KnifeChopper))
	if body is KnifeChopper && body.monitoring && body.cutting:
		knifeExited = body.position
		var line = _correctChopLine([knifeEntered, knifeExited])
		_chop(line, foodShape.polygon)		


func _correctChopLine(line: PackedVector2Array):
#	Move points to relative position and make sure they sit on the borders of the shape
	return  _getLineOnShape(
			[_toRelativePositon(line[0]), _toRelativePositon(line[1])],
			 foodShape.polygon)


func _toRelativePositon(p1: Vector2):
	var dist = global_position - position
	return p1 - dist


func _chop (line: PackedVector2Array, polygon: PackedVector2Array):
	var thiccLine = g.offset_polyline(line, lineExpansion)[0]
	var clip = g.clip_polygons(polygon, thiccLine)
	if clip.size():
		var poly1 = clip[0]
		var poly2 = clip[0]

		foodShape.polygon = poly1
		collisionNode.set_deferred("polygon", poly1)
		chopped.emit(poly2)
	chopped.emit([])


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
