extends Health
class_name HealthWater

enum WATER_TEMP {COOL, WARM, SIMMER_LO, SIMMER_HI, BOIL_LO, BOIL_HI}
signal tempUpdated(val: int)

@export var hurtbox: Hurtbox

@export_group('Temp Values')
@export var warm = 50
@export var simmerLo = 100
@export var simmerHi = 130
@export var boilLo = 160
@export var boilHi = 200

@export var coolRate = 3

var temp: WATER_TEMP = WATER_TEMP.COOL


func _process(delta: float) -> void:
	if health != 0:
		health -= coolRate * delta

func setHealth(val: float):
	if val != health:
		health = clamp(val, min, max)
		_setTemp(health)


func _setTemp(val: float):
	var newTemp: WATER_TEMP

	if val < warm:
		newTemp = WATER_TEMP.COOL
	elif val < simmerLo:
		newTemp = WATER_TEMP.WARM
	elif val < simmerHi:
		newTemp = WATER_TEMP.SIMMER_LO
	elif val < boilLo:
		newTemp = WATER_TEMP.SIMMER_HI
	elif val < boilHi:
		newTemp = WATER_TEMP.BOIL_LO
	else:
		newTemp = WATER_TEMP.BOIL_HI

	if newTemp != temp:
		temp = newTemp;
		tempUpdated.emit(temp)