extends Camera2D

enum CameraMode {PREP, SERVE}

@export var cameraMoveWait = .2;

var rng = RandomNumberGenerator.new()
var shakeStrength := 0.0
@export var randomStrength := 15.0
@export var shakeFade := 5


func _ready() -> void:
	_connectListeners()
	
func _process(delta: float) -> void:
	if shakeStrength > 0: _shake(delta)

func _connectListeners():
	SignalBus.cameraShake.connect(_applyShake)

# Camera Shake
func _applyShake():
	shakeStrength = randomStrength

func _shake(delta):
	shakeStrength = lerpf(shakeStrength, 0, shakeFade * delta)
	offset = randomOffset()
func randomOffset():
	return Vector2(rng.randf_range(-shakeStrength, shakeStrength), rng.randf_range(-shakeStrength, shakeStrength))
