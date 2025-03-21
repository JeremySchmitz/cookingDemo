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
	var organs = updateOrgans(poly1)
	_createChunk(poly1, poly2, organs)
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
	#DEBUG
	#slice.color = Color(0,1,0,1)
	group.add_child(slice)
	
	
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
	
func _createChunk(poly1: PackedVector2Array, poly2: PackedVector2Array, newOrgans: Dictionary) -> void:
	if !poly1.size():
		return
	
	var chunk: Node2D = await scene.instantiate()
	_updateChunk.call_deferred(chunk, poly2, poly1, newOrgans)
	
func _updateChunk(chunk: Node2D, poly: PackedVector2Array, chopPoly: PackedVector2Array, newOrgans: Dictionary):
	chunk.position = get_parent().position
	if "collisionPoly" in chunk:
		chunk.collisionPoly.polygon = poly
		
	for child in chunk.get_children():
		if child is Choppable:
			child.addChops(chopPoly)
			if "replaceOrgans" in child:
				child.replaceOrgans.call_deferred(newOrgans)
		
	get_parent().add_sibling(chunk)	

func replaceOrgans(newOrgans: Dictionary):
	var organs
	var vOrgans
	
	if "organs" in newOrgans:
		organs = newOrgans.organs
	if "vOrgans" in newOrgans:
		vOrgans = newOrgans.vOrgans
		
	var siblings = get_parent().get_children()
	if !organs and !vOrgans:
		return
	
	for child in siblings:
		if child.name == "Organs" and organs:
			for n in child.get_children():
				child.remove_child(n)
				n.queue_free()
			for organ in organs:
				(organ as Node2D).get_parent().remove_child(organ)
				child.add_child(organ)
				
		elif child.name == "VisibleOrgans" and vOrgans:
			for n in child.get_children():
				child.remove_child(n)
				n.queue_free()
			for organ in vOrgans:
				(organ as Node2D).get_parent().remove_child(organ)
				child.add_child(organ)

func updateOrgans(newPoly: PackedVector2Array):
	var siblings = get_parent().get_children()
	var organs
	var vOrgans
	var removeOrgans = []
	var removeVOrgans = []
	for child in siblings:
		if child.name == "Organs": organs = child.get_children()
		elif child.name == "VisibleOrgans": vOrgans = child.get_children()
	
	var globalPoly = _getGlobalPoly(newPoly)
	
	if organs:
		for organ in organs:
			if organ is not Organ: break
			var organCenter = _getGobalCenter(organ.global_position, organ.polygon)
			if !Geometry2D.is_point_in_polygon(organCenter, globalPoly):
				removeOrgans.append(organ)
	if vOrgans:
		for organ in vOrgans:
			if organ is not Organ: break
			var organCenter = _getGobalCenter(organ.global_position, organ.polygon)
			if !Geometry2D.is_point_in_polygon(organCenter, globalPoly):
				removeVOrgans.append(organ)
	return {"organs":removeOrgans, "vOrgans": removeVOrgans}


func _getGobalCenter(globalPos:Vector2, points: PackedVector2Array) -> Vector2:
	var avg = Vector2(0,0)
	for p in points:
		avg += p
	avg /= points.size()
	
	return globalPos + avg
	
	
func _getGlobalPoly(poly: PackedVector2Array) -> PackedVector2Array:
	var newPoly = []
	for p in poly:
		newPoly.append(global_position + p)
	return newPoly
