class_name Bone
extends Area2D

@export var sliceable = false
@export var choppable = false
@export var breakable = false

func chop():
	if choppable && breakable:
		queue_free()
