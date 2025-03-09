class_name FoodChunkArea

extends Area2D

var lifted = false
@onready var collider: FoodChunkCollision = get_child(0)

func _unhandled_input(event):
	if event is InputEventMouseButton and not event.pressed:
		lifted = false
	if lifted and event is InputEventMouseMotion:
		get_parent().position += event.relative

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		lifted = true
