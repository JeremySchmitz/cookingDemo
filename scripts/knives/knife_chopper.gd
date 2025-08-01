class_name KnifeChopper
extends Knife

signal cutBone(pos: Vector2)

var active: bool = false
var cutting: bool = false


func _process(_delta):
	if (active):
		global_position = get_global_mouse_position()
		if inCuttingBoard && Input.is_action_just_pressed("left_click"):
			cutting = true
		elif inCuttingBoard && Input.is_action_just_released("left_click"):
			cutting = false
	else:
		global_position = Vector2(-10, -10)
		
func _on_mode_change(m: GlobalEnums.Mode):
	match m:
		GlobalEnums.Mode.CHOP:
			active = true
		_:
			active = false

func _on_area_entered(body: Area2D):
	super._on_area_entered(body)
	if cutting && body is Bone:
		if !body.choppable:
			cutting = false
			cutBone.emit(body.global_position)
		(body as Bone).chop()
