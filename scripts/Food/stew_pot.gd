extends Dishwear
class_name StewPot

@export var waterDamage: Array[int] = []

@onready var hitbox: Hitbox = $Hitbox
@onready var anim: AnimationPlayer = %StewAnimPlayer

func _on_health_water_temp_updated(val: int) -> void:
	print('waterDamage[val]', waterDamage[val])
	if waterDamage[val] != null:
		hitbox.damage = waterDamage[val]
		match val:
			0:
				anim.play('RESET')
			1:
				anim.play('RESET')
			2:
				anim.play('Stew_Simmer_low')
			3:
				anim.play('Stew_Simmer_hi')
			4:
				anim.play('Stew_Boil_low')
			5:
				anim.play('Stew_Boil_hi')
