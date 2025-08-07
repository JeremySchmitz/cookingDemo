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

var rng = RandomNumberGenerator.new()
var shakeStrength := 0.0
@export var randomStrength := 15.0
@export var shakeFade := 5


func _ready() -> void:
	_connectListeners()
	_initializeTimer()
	
func _process(delta: float) -> void:
	var curPos = cam.get_screen_center_position()
	if !moving && curPos != lastPos:
		SignalBus.cameraMove.emit()
		moving = true
	elif moving && curPos == lastPos:
		SignalBus.cameraStop.emit()
		moving = false
	
	lastPos = curPos

	if shakeStrength > 0: _shake(delta)

# Listeners
func _connectListeners():
	toRight.mouse_entered.connect(_on_to_right_area_mouse_entered)
	toRight.mouse_exited.connect(_on_to_right_area_mouse_exited)
	toLeft.mouse_entered.connect(_on_to_left_area_mouse_entered)
	toLeft.mouse_exited.connect(_on_to_left_area_mouse_exited)

	SignalBus.cameraShake.connect(_applyShake)

func _on_to_right_area_mouse_entered() -> void:
	if curCam == CameraMode.PREP && !holdCam:
		_build_timer(
			Vector2(get_viewport().get_visible_rect().size.x, position.y),
			CameraMode.SERVE
			)

func _on_to_right_area_mouse_exited() -> void:
	if timers.has("toServe"):
		timers["toServe"].stop()

func _on_to_left_area_mouse_entered() -> void:
	if curCam == CameraMode.SERVE && !holdCam:
		_build_timer(Vector2(0, 0), CameraMode.PREP)

func _on_to_left_area_mouse_exited() -> void:
	if timers.has("toPrep"):
		timers["toPrep"].stop()

# Move Camera
func _initializeTimer():
	camHoldTimer = Timer.new()
	camHoldTimer.one_shot = true
	camHoldTimer.wait_time = .5
	camHoldTimer.connect("timeout", _setHold.bind(false))
	add_child(camHoldTimer)

func _build_timer(pos: Vector2, camMode: CameraMode):
	var timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timers[camMode] = timer;
	timer.wait_time = cameraMoveWait
	timer.connect("timeout", _move_camera.bind(pos, camMode))
	timer.start()

func _move_camera(pos: Vector2, newCam: CameraMode):
	position = pos;
	curCam = newCam
	timers.erase(newCam)
	
	holdCam = true;
	camHoldTimer.start()
	
func _setHold(val: bool):
	holdCam = val

# Camera Shake
func _applyShake():
	shakeStrength = randomStrength

func _shake(delta):
	shakeStrength = lerpf(shakeStrength, 0, shakeFade * delta)
	offset = randomOffset()
func randomOffset():
	return Vector2(rng.randf_range(-shakeStrength, shakeStrength), rng.randf_range(-shakeStrength, shakeStrength))
