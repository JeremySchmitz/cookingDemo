class_name Choppable
extends CanvasGroup

var g = Geometry2D

const maxFloatSize: float = 99999.0
const cutLineGrow = 200
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
		var line = _correctChopLine(knifeEntered, knifeExited)
		_chop(line, collisionNode.polygon)		


func _correctChopLine(start: Vector2, end: Vector2):
	var relStart = _toRelativePositon(start)
	var relEnd = _toRelativePositon(end)
	var dir = (relEnd - relStart).normalized()
	
	var newStart = relStart + (dir * -cutLineGrow)
	var newEnd = relEnd + (dir * cutLineGrow)
#	Move points to relative position and make sure they sit on the borders of the shape
	return  [newStart, newEnd]


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
	
#	has to happen before we add chops to this food or we'll include what we just created
	var siblingChop = _getExistingChopPolys()

	addChops(poly2)
	var organs = updateOrgans(poly1)
	_createChunk([poly1, siblingChop], poly2, organs)
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
	
	
func _createChunk(chops: Array[PackedVector2Array], poly2: PackedVector2Array, newOrgans: Dictionary) -> void:
	if !chops.size() || !chops[0].size():
		return
	
	var chunk: Node2D = await scene.instantiate()
	_updateChunk.call_deferred(chunk, poly2, chops, newOrgans)
	

func _updateChunk(chunk: Node2D, poly: PackedVector2Array, chops: Array[PackedVector2Array], newOrgans: Dictionary):
	chunk.position = get_parent().position
	if "collisionPoly" in chunk:
		chunk.collisionPoly.polygon = poly
		
	if "parented" in chunk and "parented" in get_parent():
		chunk.parented = get_parent().parented
		
	if "health" in chunk:
		(chunk.health as Health).cooked = get_parent().health.cooked
		chunk.polygon2D.color = get_parent().polygon2D.color
		
	for child in chunk.get_children():
		if child is Choppable:
			for chop in chops:
				child.addChops(chop)
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
	
	for sibling in siblings:
		if sibling.name == "Organs":
			for n in sibling.get_children():
				sibling.remove_child(n)
				n.queue_free()
			if !organs: break
			for organ in organs:
				(organ as Node2D).reparent(sibling)
				
		elif sibling.name == "VisibleOrgans":
			for n in sibling.get_children():
				sibling.remove_child(n)
				n.queue_free()
			if !vOrgans: break
			for organ in vOrgans:
				(organ as Node2D).reparent(sibling)

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

func _getExistingChopPolys():
	var chopGroup: Choppable
	for s in get_parent().get_children():
		if s is Choppable:
			chopGroup = s;
			break
			
	if !chopGroup: return;
	
	var polys: Array[PackedVector2Array] = []
	for c in chopGroup.get_children():
		if c is Polygon2D:
			polys.append(c.polygon)
			
			
	var newPoly: PackedVector2Array = []
			
	for poly in polys:
		newPoly = g.merge_polygons(newPoly, poly)[0]
			
	return newPoly
