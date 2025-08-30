extends Control
class_name Clock

const TIME_BUFFER = .01

signal done()
signal encounterCheck()

@export var duration: float
@export var encounterPeriod: float = .5
@export var timeScale := 1.0
@onready var sprite: AnimatedSprite2D = $%AnimatedSprite2D
@onready var frameCount: int = sprite.sprite_frames.get_frame_count('default')
var started = false
var timeLeft: float
var time := 0.0
var encounterTime := 0.0
func _ready() -> void:
	start()


func _process(delta: float) -> void:
	if started:
		time += delta * timeScale
		encounterTime += delta * timeScale
		timeLeft = duration - time
		_updateAnimation()
		if time >= duration: _done()
		if encounterTime >= encounterPeriod:
			encounterTime = 0
			encounterCheck.emit()


func start():
	started = true

func pause():
	started = false

func _done():
	started = false
	time = 0.0
	done.emit()

func _updateAnimation():
	var frame = remap(time, 0, duration, 0, frameCount)
	sprite.frame = floor(frame)
