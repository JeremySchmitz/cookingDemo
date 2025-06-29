extends Node2D
enum Mode {CHOP, SLICE, GRAB}
enum CameraMode {PREP, SERVE}

@export var cameraMoveWait = .2;

var curMode = Mode.CHOP
var curCam: CameraMode = CameraMode.PREP
var timers: Dictionary = {}
var camHoldTimer: Timer
var holdCam = false

func _ready() -> void:
	camHoldTimer = Timer.new()
	camHoldTimer.one_shot = true
	camHoldTimer.wait_time = .5
	camHoldTimer.connect("timeout", _setHold.bind(false))
	add_child(camHoldTimer)

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

func _on_to_serve_area_mouse_entered() -> void:
	if curCam == CameraMode.PREP  && !holdCam:
		_build_timer(
			Vector2(get_viewport().get_visible_rect().size.x,$CameraMain.position.y),
			CameraMode.SERVE
			)

func _on_to_serve_area_mouse_exited() -> void:
	if timers.has("toServe"):
		timers["toServe"].stop()

func _on_to_prep_area_mouse_entered() -> void:
	if curCam == CameraMode.SERVE && !holdCam:
		_build_timer(Vector2(0, 0), CameraMode.PREP)

func _on_to_prep_area_mouse_exited() -> void:
	if timers.has("toPrep"):
		timers["toPrep"].stop()
		
func _build_timer(pos: Vector2, camMode: CameraMode):
	var timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timers[camMode] = timer;
	timer.wait_time = cameraMoveWait
	timer.connect("timeout", _move_camera.bind(pos, camMode))
	timer.start()

func _move_camera(pos: Vector2, newCam: CameraMode):
	$CameraMain.position = pos;
	curCam = newCam
	timers.erase(newCam)
	
	holdCam = true;
	camHoldTimer.start()
	
func _setHold(val: bool):
	holdCam = val
