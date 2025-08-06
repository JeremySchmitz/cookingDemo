extends Hurtbox
class_name Hand

func _ready():
	connect("area_entered", _on_area_entered)
	connect("area_exited", _on_area_exited)
	recievedDamage.connect(_drop)

func _process(delta: float) -> void:
	global_position = get_global_mouse_position()

func _drop(damage):
	Utils.cameraShake.emit()
	Utils.stopDrag.emit()
