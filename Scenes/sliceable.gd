class_name Sliceable
extends Node2D

signal sliced(line: PackedVector2Array)

const sliceMaterial = preload("res://resources/subtract.material")

const angle1 = 20 * PI/180
const angle2 = 10 * PI/180
const percent1 = 0.2
const percent2 = 0.3

@export var collisionArea: Area2D
@export var group: CanvasGroup


var knifeInside = false
var sliceStart: Vector2


func _ready() -> void:
	collisionArea.area_entered.connect(_on_area_entered)
	collisionArea.area_exited.connect(_on_area_exited)
	

func slice(line: PackedVector2Array):
	if line[0].x < line[1].x:
		var tp = line[1]
		line[1] = line[0]
		line[0] = tp
		
	var dist = line[0].distance_to(line[1])
	var dir = (line[1] - line[0]).normalized()
	
	var p1 = line[0] + (dir.rotated(-angle1) * dist * percent1)
	var p2 = p1 + (dir.rotated(-angle2) * dist * percent2)
	var p3 = line[1] - (dir.rotated(angle1) * dist * percent1)
	
	var p4 = line[1] - (dir.rotated(-angle1) * dist * percent1)
	var p5 = p4 - (dir.rotated(-angle2) * dist * percent2)
	var p6 = line[0] + (dir.rotated(angle1) * dist * percent1)
	
	
	var newLine = [line[0], p1, p2, p3, line[1], p4, p5, p6]
	
	for i in range(0, newLine.size()):
		newLine[i] = newLine[i] - global_position
		
	_addNewSlice(newLine)
	sliced.emit(newLine)
	
func _addNewSlice(line: PackedVector2Array):
	var newSlice = Polygon2D.new()
	newSlice.polygon = line
	newSlice.color = Color(0,1,0,1)
	newSlice.clip_children = true
	newSlice.material = sliceMaterial
	group.add_child(newSlice)


func _on_area_entered(body: Area2D):
	if body is KnifeSlicer && body.active:
		knifeInside = true
		Signals.startSlice.connect(_on_start_slice)
		Signals.endSlice.connect(_on_end_slice)


func _on_area_exited(body: Area2D):
	if body is KnifeSlicer && body.active:
		knifeInside = false
		Signals.startSlice.disconnect(_on_start_slice)
		Signals.endSlice.disconnect(_on_end_slice)


func _on_start_slice(p: Vector2):
	sliceStart = p;

func _on_end_slice(p: Vector2):
	slice([sliceStart, p])
	sliceStart = Vector2(-1,-1)
