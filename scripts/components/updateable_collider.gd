class_name UpdateableCollider
extends CollisionPolygon2D

@export var collisionShape: CollisionPolygon2D
@export var updateOn: String

func _ready():
	_update()

## TODO This may cause performance issues
## BUG this breaks if youre cutting to quickly
func _process(_delta: float) -> void:
	if polygon != collisionShape.polygon:
		_update()

func _update():
	set_deferred("polygon", collisionShape.polygon)
