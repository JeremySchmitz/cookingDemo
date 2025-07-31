extends Area2D
class_name KnifeButton

signal valChange(val: bool)

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var mouse_over = false
var draggable: bool = true

var value = false:
	set(val):
		value = val
		updateAnim()

func _ready():
	connect("mouse_entered", _mouse_over.bind(true))
	connect("mouse_exited", _mouse_over.bind(false))

func _mouse_over(val):
	mouse_over = val
	updateAnim()

func _unhandled_input(event):
	if (mouse_over
			and event is InputEventMouseButton
			and event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed
		):
			value = !value
			valChange.emit(value)

func updateAnim():
	if value:
		if mouse_over: sprite.animation = "in_use_hover"
		else: sprite.animation = "in_use"
	else:
		if mouse_over: sprite.animation = "ready_hover"
		else: sprite.animation = "ready"
