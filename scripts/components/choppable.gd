class_name Choppable
extends CanvasGroup

var g = Geometry2D

const maxFloatSize: float = 99999.0
const cutLineGrow = 200
const lineExpansion = 1
const sperationSize = 5;
const sliceMaterial = preload("res://resources/subtract.material")

signal chopped(percentage: float)

@export var collisionArea: Area2D
@export var collisionNode: CollisionPolygon2D
@export var sliceGroup: CanvasGroup
@export var scenePath: String

var scene: PackedScene
var area: float

var knifeEntered: Vector2
var knifeExited: Vector2

func _ready() -> void:
	scene = load(scenePath)
	collisionArea.area_entered.connect(_on_area_entered)
	collisionArea.area_exited.connect(_on_area_exited)
	area = _getAreaOfPolygon(collisionNode.polygon)


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
	return [newStart, newEnd]


func _toRelativePositon(p1: Vector2):
	var dist = global_position - position
	return p1 - dist


func _chop(line: PackedVector2Array, polygon: PackedVector2Array):
	var thiccLine = g.offset_polyline(line, lineExpansion)[0]
	var clip = g.clip_polygons(polygon, thiccLine)
	
	var poly1 = g.offset_polygon(clip[0], lineExpansion)[0]
	var poly2 = g.offset_polygon(clip[1], lineExpansion)[0]
	collisionNode.set_deferred("polygon", poly1)
	
#	has to happen before we add chops to this food or we'll include what we just created
	var siblingChop = _getExistingChopPolys()
	
	var newPos = _getSeperatedPositions(poly1, poly2)
	get_parent().position = newPos[0]
	
	addChops(poly2)
	var organs = updateOrgans(poly1)
	_createChunk([poly1, siblingChop], poly2, organs, newPos[1])
	
	call_deferred("_updateArea", poly1)


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
	
	
func _createChunk(chops: Array[PackedVector2Array], poly2: PackedVector2Array, newOrgans: Dictionary, pos: Vector2) -> void:
	if !chops.size() || !chops[0].size():
		return
	
	var chunk: Food = await scene.instantiate()
	_updateChunk.call_deferred(chunk, poly2, chops, newOrgans, pos)
	

func _updateChunk(chunk: Food, poly: PackedVector2Array, chops: Array[PackedVector2Array], newOrgans: Dictionary, pos: Vector2):
	chunk.spriteScaleSet = true
	get_parent().add_sibling(chunk)
	
	if chunk.collisionPoly:
		chunk.collisionPoly.polygon = poly
		
	if "parented" in chunk and "parented" in get_parent():
		chunk.parented = get_parent().parented
		
	if "health" in chunk:
		(chunk.health as Health).health = (get_parent() as Food).health.cooked

	for child in chunk.get_children():
		if child is Choppable:
			child._updateArea(poly)
			for chop in chops:
				if chop.size(): child.addChops(chop)
			if "replaceOrgans" in child:
				child.replaceOrgans.call_deferred(newOrgans)
	
	chunk.position = pos

		
func replaceOrgans(newOrgans: Dictionary):
	var organs
	var vOrgans
	var bones

	if "organs" in newOrgans:
		organs = newOrgans.organs
	if "vOrgans" in newOrgans:
		vOrgans = newOrgans.vOrgans
	if "bones" in newOrgans:
		bones = newOrgans.bones
		
	var siblings = get_parent().get_children()
	
	for sibling in siblings:
		if sibling.name == "Organs":
			for n in sibling.get_children():
				sibling.remove_child(n)
				n.queue_free()

			if organs:
				for organ in organs: (organ as Node2D).reparent(sibling)
				
		elif sibling.name == "VisibleOrgans":
			for n in sibling.get_children():
				sibling.remove_child(n)
				n.queue_free()

			if vOrgans:
				for organ in vOrgans: (organ as Node2D).reparent(sibling)
		
		elif sibling.name == "Bones":
			for n in sibling.get_children():
				sibling.remove_child(n)
				n.queue_free()

			if bones:
				for organ in bones:
					(organ as Node2D).reparent(sibling)
					(organ as Node2D).position = Vector2(0, 0)

func updateOrgans(newPoly: PackedVector2Array):
	var siblings = get_parent().get_children()
	var organs
	var vOrgans
	var bones
	var removeOrgans = []
	var removeVOrgans = []
	var removeBones = []

	for child in siblings:
		if child.name == "Organs": organs = child.get_children()
		elif child.name == "VisibleOrgans": vOrgans = child.get_children()
		elif child.name == "Bones": bones = child.get_children()
	
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

	if bones:
		for bone in bones:
			if bone is not Bone: break
			var boneCenter = _getGobalCenter(bone.get_child(0).global_position, bone.get_child(0).polygon)
			if !Geometry2D.is_point_in_polygon(boneCenter, globalPoly):
				removeBones.append(bone)
				
	return {"organs": removeOrgans, "vOrgans": removeVOrgans, "bones": removeBones}


func _getGobalCenter(globalPos: Vector2, points: PackedVector2Array) -> Vector2:
	var avg = Vector2(0, 0)
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
			
	if !chopGroup: return ;
	
	var polys: Array[PackedVector2Array] = []
	for c in chopGroup.get_children():
		if c is Polygon2D:
			polys.append(c.polygon)
			
			
	var newPoly: PackedVector2Array = []
			
	for poly in polys:
		newPoly = g.merge_polygons(newPoly, poly)[0]
			
	return newPoly

func _getSeperatedPositions(poly1: PackedVector2Array, poly2: PackedVector2Array):
	var c1 = Vector2(0, 0)
	var c2 = Vector2(0, 0)
	
	for poly in poly1:
		c1 += poly
	for poly in poly2:
		c2 += poly
	c1 /= poly1.size()
	c2 /= poly2.size()
	
	var dir = (c1 - c2).normalized()
	var p1 = get_parent().position + (dir * sperationSize)
	var p2 = get_parent().position - (dir * sperationSize)
	return [p1, p2]
	
func _updateArea(ps: PackedVector2Array):
	var newArea = _getAreaOfPolygon(ps)
	var percent = newArea / area
	area = newArea
	chopped.emit(percent)
	
func _getAreaOfPolygon(ps: PackedVector2Array) -> float:
	var sum = 0.0
	for i in range(0, ps.size() - 1):
		var p1 = ps[i]
		var p2 = ps[i + 1]
		sum += (p2.x - p1.x) * (p1.y + p2.y)
	
	return abs(sum) * 0.5
