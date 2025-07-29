extends Node2D

@onready var burner: AnimatedSprite2D = $Burner
@onready var hitbox: Hitbox = $Pan/hitbox


func _on_dial_val_set(val: int) -> void:
	print('dial set: ', val)
	if !burner || !hitbox: return
	match val:
		1:
			burner.animation = "on_low"
			hitbox.damage = 3
		2:
			burner.animation = "on_med"
			hitbox.damage = 8
		3:
			burner.animation = "on_high"
			hitbox.damage = 20
		_:
			burner.animation = "default"
			hitbox.damage = 0
