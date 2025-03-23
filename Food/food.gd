class_name Food
extends Node2D

@export var polygon2D: Polygon2D
@export var collisionPoly: CollisionPolygon2D

var draggable = false

func _ready():
	Signals.modeChange.connect(_on_mode_change)

func _on_mode_change(m: GlobalEnums.Mode):
	match m:
		GlobalEnums.Mode.GRAB:
			draggable = true
		_:
			draggable = false
