extends Node2D

@onready var burner: AnimatedSprite2D = $Burner
@onready var hitbox: Hitbox = $Pan/hitbox
@export var damage: Array[float] = [0, 3, 8, 20]


func _on_dial_val_set(val: int) -> void:
	print('dial set: ', val)
	if !burner || !hitbox: return
	match val:
		1:
			burner.animation = "on_low"
			hitbox.damage = damage[val]
		2:
			burner.animation = "on_med"
			hitbox.damage = damage[val]
		3:
			burner.animation = "on_high"
			hitbox.damage = damage[val]
		_:
			burner.animation = "default"
			hitbox.damage = damage[val]
