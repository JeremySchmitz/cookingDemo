extends Area2D

signal valSet(val: int)

@export var turnDeg = 30.0 # deg
@export var increments = 4
@export var snapDist = 15.0 # deg
@export var snapMin = -60.0

@onready var knob = $Knob

var mouse_over = false
var dragging = false

var curVal: int = -1


func _ready():
	connect("mouse_entered", _mouse_over.bind(true))
	connect("mouse_exited", _mouse_over.bind(false))

func _unhandled_input(event):
	if (mouse_over
		and event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.pressed
	):
		dragging = true
		
	if event is InputEventMouseButton and not event.pressed:
		dragging = false
		
	if dragging and event is InputEventMouseMotion:
		updateRotation(get_global_mouse_position())
		get_viewport().set_input_as_handled()

func _mouse_over(value):
	mouse_over = value

func updateRotation(mousePos: Vector2):
	var dir: Vector2 = (mousePos - knob.global_position).normalized()
	var angle = rad_to_deg(dir.angle() + PI / 2)
	var mod = fmod(angle, turnDeg)
	var outsideRange = angle < (snapMin - snapDist) || angle > snapMin + (turnDeg * increments) + snapDist

	if !outsideRange:
		if abs(mod) <= snapDist:
			angle -= mod
		else:
			angle += floor(angle / turnDeg) - mod

	knob.rotation = deg_to_rad(angle)
	_setVal(angle)

# angle in deg
func _setVal(angle: float):
	var val = floor((angle - snapMin) / turnDeg)
	if val > increments - 1 || val < -1: val = -1

	curVal = int(val)
	valSet.emit(val)
