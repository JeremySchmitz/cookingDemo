extends Node2D
class_name Port

@onready var resource: PortResource: set = _setPortResource
@onready var label: Label = $Label
@onready var info: Info = $Info

@export var labelName := '':
	set(val):
		labelName = val
		label.text = labelName
		info.text = labelName
		_setLabel()

var mouse_over
var select := false
var distance := 0.0:
	set(val):
		distance = val
		_setLabel()

var ignoreSelected = false
			
# TODO Flip if not visible

func _ready() -> void:
	if Engine.is_editor_hint(): return
	label.text = labelName
	info.text = labelName
	
	connect("mouse_entered", _mouse_over.bind(true))
	connect("mouse_exited", _mouse_over.bind(false))
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	SignalBus.portClicked.connect(on_port_selected)

func _setPortResource(val: PortResource):
	resource = val
	position = val.position
	labelName = val.name

func _unhandled_input(event: InputEvent):
	if (event is InputEventMouseButton
		and mouse_over
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.pressed):
			info.visible = !info.visible
			SignalBus.portClicked.emit(name)


func _mouse_over(value):
	mouse_over = value


func _on_travel_btn_pressed() -> void:
	SignalBus.portSelected.emit(global_position)
	info.visible = false

func on_port_selected(portName: String):
	if name != portName:
		info.visible = false

func _setLabel():
	# TODO is this way till can find more accurate calc
	# var text = "Port {0} \nLess than {1} day(s) travel".format([labelName, int(distance)])
	if resource:
		var newText = '
		priceBonus: {0}
		pricePenalty: {1}
		difficulty: {2}
		'.format(
			[resource.priceBonus,
			resource.pricePenalty,
			GlobalEnums.Difficulty.find_key(resource.difficulty)]
		)

		info.text = newText

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("boats"):
		SignalBus.canDock.emit(true)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("boats"):
		SignalBus.canDock.emit(false)
