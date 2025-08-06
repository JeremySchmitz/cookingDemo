extends Node2D
class_name Port


@onready var label: Label = $Label
@onready var info: Info = $Info

@export var labelName := ''

var mouse_over
var select := false
var distance := 0.0:
	set(val):
		distance = val
		# TODO is this way till can find more accurate calc
		info.text = "Port {0} \nLess than {1} day(s) travel".format([labelName, int(val)])

var ignoreSelected = false
			
# TODO Flip if not visible

func _ready() -> void:
	label.text = labelName
	info.text = labelName
	
	connect("mouse_entered", _mouse_over.bind(true))
	connect("mouse_exited", _mouse_over.bind(false))
	Utils.portClicked.connect(on_port_selected)

func _unhandled_input(event: InputEvent):
	if (event is InputEventMouseButton and
		mouse_over and
		event.pressed):
			info.visible = !info.visible
			Utils.portClicked.emit(name)


func _mouse_over(value):
	mouse_over = value


func _on_travel_btn_pressed() -> void:
	Utils.portSelected.emit(global_position)
	info.visible = false

func on_port_selected(portName: String):
	if name != portName:
		info.visible = false