extends Node2D
enum Mode {CHOP, SLICE, GRAB}

const bowlScene = preload("res://Scenes/food/bowl.tscn")

@export var cameraMoveWait = .2;

var curMode = Mode.CHOP
@onready var crew:= CrewStatus.crew

func _ready() -> void:
	for i in range(0, crew.size()):
		_buildBowl(i)
	pass

func _buildBowl(i: int):
	var scene: Bowl = bowlScene.instantiate()
	scene.setNameTag("{0} ({1})".format([crew[i].name, GlobalEnums.Role.keys()[crew[i].role]]))
	add_child(scene)
	scene.scale *= 2
	scene.position = Vector2(
		get_viewport_rect().size.x + 200 + (300 * i),
		 200 )
	


func _on_chop_btn_pressed() -> void:
	curMode = Mode.CHOP
	$chopBtn.disabled = true
	$sliceBtn.disabled = false
	$grabBtn.disabled = false
	Utils.modeChange.emit(curMode)
	get_tree().get_root().set_input_as_handled()

func _on_grab_btn_pressed() -> void:
	curMode = Mode.GRAB
	$chopBtn.disabled = false
	$sliceBtn.disabled = false
	$grabBtn.disabled = true
	Utils.modeChange.emit(curMode)
	get_tree().get_root().set_input_as_handled()

func _on_slice_btn_pressed() -> void:
	curMode = Mode.SLICE
	$chopBtn.disabled = false
	$sliceBtn.disabled = true
	$grabBtn.disabled = false
	Utils.modeChange.emit(curMode)
	get_tree().get_root().set_input_as_handled()
