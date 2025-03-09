extends Node2D
enum Mode {CHOP, SLICE, GRAB}

var g = Geometry2D
var curMode = Mode.CHOP
@onready var foodChunks: Node2D = get_node_or_null("foodChunks")

const foodChunkPacked = preload("res://food_chunk.tscn")


func _unhandled_input(event) -> void:
	match curMode:
		Mode.CHOP:
			$knifeChop.action(event)
		Mode.SLICE:
			pass
		Mode.GRAB:
			pass
			
			
# CHOPPING
func _chop (line: PackedVector2Array, chunk: FoodChunk):
	var polygon = chunk.polygon
	var worldPoly = _setToWorld(chunk)
	var ch1Poly = PackedVector2Array()
	var ch2Poly = PackedVector2Array()
	
	var intersect1 = false
	var intersect2 = false
	for i in range(0, polygon.size()):
		var p1 = worldPoly[i]
		var i2:int = (i + 1) if i + 1 < polygon.size() else 0
		var p2 = worldPoly[i2] 
#		If we are before or after the intersection add point
		if (!intersect1 && !intersect2) or (intersect1 && intersect2):  
			ch1Poly.append(p1)
#		If we are between intersections add Point
		else:
			ch2Poly.append(p1)	
			
#		If we intersect with the first point add intersections to ch1
#		and first intersection to ch2
		if _online(worldPoly[i], worldPoly[i2], line[0]):
			ch1Poly.append(line[0])
			ch1Poly.append(line[1])
			ch2Poly.append(line[0])	
			intersect1 = true
#		If we intersect with the second point and second intersection to ch2
		elif _online(p1, p2, line[1]):
			ch2Poly.append(line[1])	
			intersect2 = true
			
	return [ch1Poly, ch2Poly]
#
	#var ch1: FoodChunk = foodChunkPacked.instantiate()
	#var ch2: FoodChunk = foodChunkPacked.instantiate()
	#
	#
	#ch1.polygon = ch1Poly
	#ch1.cooked = cooked
	#ch2.polygon = ch2Poly
	#ch2.cooked = cooked
	#
##	TODO Update to move apart
	#var x = rng.randf_range(10, 50)
	#var y = rng.randf_range(10, 50)
	#
	##TODO This doesnt work becase the ch position is set to the origin even though the polygon is not
	#var dir = _getDirection(ch1, ch2)
	##var dist = dir * gapSize
	##ch1.move_local_x(-dist.x)
	##ch1.move_local_y(-dist.y)
	##ch2.move_local_x(dist.x)
	##ch2.move_local_y(dist.y)
	#
	#var chunks = get_parent()
	#chunks.add_child(ch1)
	#chunks.add_child(ch2)
	#queue_free()
	


func _checkInside(chunk: PackedVector2Array, cut: PackedVector2Array)-> bool:
	return g.is_point_in_polygon(cut[0],chunk) || g.is_point_in_polygon(cut[1],chunk)


func _newChunk(poly: PackedVector2Array, cooked: float ):
	var chunk = foodChunkPacked.instantiate()
	chunk.polygon = poly
	chunk.cooked = cooked
	foodChunks.add_child(chunk)
	return chunk
	
	
func _online (p1: Vector2, p2: Vector2, p3: Vector2):
	var dist1 = floor(p1.distance_to(p2))
	var dist2 = floor(p1.distance_to(p3) + p2.distance_to(p3))
	return dist1 == dist2


func _getIntersections(worldPoly: PackedVector2Array, cut: PackedVector2Array) -> PackedVector2Array:
	var intersections: PackedVector2Array
	var ch1: Vector2
	var ch2: Vector2
	
	for i in range(0, worldPoly.size()):
		ch1 = worldPoly[i]
		ch2 = worldPoly[i + 1] if i + 1 < worldPoly.size() else worldPoly[0]
		var intersect = g.segment_intersects_segment(ch1,ch2,cut[0],cut[1])
		if intersect != null : intersections.append(intersect)
		
	return intersections


func _setToWorld(chunk: FoodChunk) -> PackedVector2Array:
	var newPoly = []
	var pos = chunk.position
	for i in range(0, chunk.polygon.size()):
		newPoly.append(chunk.polygon[i] + pos)
	return newPoly
	

# LISTENERS
func _on_chop_btn_pressed() -> void:
	curMode = Mode.CHOP
	$chopBtn.disabled = true
	$sliceBtn.disabled = false
	$grabBtn.disabled = false
	get_tree().get_root().set_input_as_handled()


func _on_fryingpan_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if(parent.name == 'FoodChunk'):
		parent.cooking = 50


func _on_fryingpan_area_exited(area: Area2D) -> void:
	var parent = area.get_parent()
	if(parent.name == 'FoodChunk'):
		parent.cooking = 0


func _on_grab_btn_pressed() -> void:
	curMode = Mode.GRAB
	$chopBtn.disabled = false
	$sliceBtn.disabled = false
	$grabBtn.disabled = true
	get_tree().get_root().set_input_as_handled()
	
	
func _on_knife_chop_stroke_finished(line: PackedVector2Array) -> void:
	if foodChunks != null:
		print('cut')
		for chunk: FoodChunk in foodChunks.get_children():
			print('chunk')
			var worldPoly = _setToWorld(chunk)
			var intersections = _getIntersections(worldPoly, line)
			print('intersections: ' + str(intersections))
			if (_checkInside(worldPoly, line)):
					print("inside")
					pass
			elif (intersections.size() > 1):
				print('chop')
				var polygons = _chop(intersections, chunk) 
				var ch1 = _newChunk(polygons[0], chunk.cooked)
				var ch2 = _newChunk(polygons[1], chunk.cooked)
				chunk.queue_free()
				
				
func _on_slice_btn_pressed() -> void:
	curMode = Mode.SLICE
	$chopBtn.disabled = false
	$sliceBtn.disabled = true
	$grabBtn.disabled = false
	get_tree().get_root().set_input_as_handled()
