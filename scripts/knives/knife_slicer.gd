class_name KnifeSlicer
extends Knife

signal cutBone(pos: Vector2)

var active: bool = false
var cutting: bool = false
var isInBone = false


func _process(_delta):
	if (active):
		global_position = get_global_mouse_position()
		if inCuttingBoard && Input.is_action_just_pressed("left_click"):
			cutting = true
			Utils.startSlice.emit(global_position)
		elif cutting && inCuttingBoard && Input.is_action_just_released("left_click"):
			cutting = false
			Utils.endSlice.emit(global_position)

	else:
		global_position = Vector2(-10, -10)
		
func _on_mode_change(m: GlobalEnums.Mode):
	match m:
		GlobalEnums.Mode.SLICE:
			active = true
		_:
			active = false

func _on_area_entered(body: Area2D):
	super._on_area_entered(body)
	if cutting && body is Bone && !(body as Bone).sliceable:
		cutting = false
		Utils.endSlice.emit(Vector2(-1, -1))
		cutBone.emit(global_position)
