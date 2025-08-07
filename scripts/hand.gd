extends Hurtbox
class_name Hand

@export var particles: CPUParticles2D

func _ready():
	super._ready()
	recievedDamage.connect(_damage)

func _process(delta: float) -> void:
	global_position = get_global_mouse_position()

func _damage(damage):
	_drop()
	_bleed()

func _drop():
	Utils.cameraShake.emit()
	Utils.stopDrag.emit()
	
func _bleed():
	particles.global_position = global_position
	particles.emitting = true
