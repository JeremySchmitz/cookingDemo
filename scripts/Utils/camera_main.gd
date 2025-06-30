extends Camera2D

enum CameraMode {PREP, SERVE}

@export var cameraMoveWait = .2;

@onready var cam: Camera2D = self
@onready var lastPos: Vector2 = cam.get_screen_center_position()
@onready var toRight: Area2D = $toRight
@onready var toLeft: Area2D = $toLeft

var moving = false;
var curCam: CameraMode = CameraMode.PREP
var timers: Dictionary = {}
var camHoldTimer: Timer
var holdCam = false

func _ready() -> void:
	toRight.mouse_entered.connect(_on_to_right_area_mouse_entered)
	toRight.mouse_exited.connect(_on_to_right_area_mouse_exited)
	toLeft.mouse_entered.connect(_on_to_left_area_mouse_entered)
	toLeft.mouse_exited.connect(_on_to_left_area_mouse_exited)
	
	camHoldTimer = Timer.new()
	camHoldTimer.one_shot = true
	camHoldTimer.wait_time = .5
	camHoldTimer.connect("timeout", _setHold.bind(false))
	add_child(camHoldTimer)
	
func _process(delta: float) -> void:
	var curPos = cam.get_screen_center_position()
	if !moving && curPos != lastPos:
		print('moving')
		Utils.cameraMove.emit()
		moving = true
	elif moving && curPos == lastPos:
		print('stoped')
		Utils.cameraStop.emit()
		moving = false
	
	lastPos = curPos


func _on_to_right_area_mouse_entered() -> void:
	if curCam == CameraMode.PREP  && !holdCam:
		_build_timer(
			Vector2(get_viewport().get_visible_rect().size.x, position.y),
			CameraMode.SERVE
			)

func _on_to_right_area_mouse_exited() -> void:
	if timers.has("toServe"):
		timers["toServe"].stop()

func _on_to_left_area_mouse_entered() -> void:
	if curCam == CameraMode.SERVE && !holdCam:
		print('toLEft')
		_build_timer(Vector2(0, 0), CameraMode.PREP)

func _on_to_left_area_mouse_exited() -> void:
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
	print('moveCam')
	position = pos;
	curCam = newCam
	timers.erase(newCam)
	
	holdCam = true;
	camHoldTimer.start()
	
func _setHold(val: bool):
	holdCam = val
