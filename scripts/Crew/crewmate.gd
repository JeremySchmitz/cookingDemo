class_name Crew

var role: GlobalEnums.Role
var name: String
var health: int
# How Susceptable they are poisoned food and how quickly they heal
var constitution: float
var maxSatiety: float = 0:
	set(val):
		maxSatiety = val
		satiety = min(satiety, val)
var satiety: float
var strength: int
var fishing: int
var sanity: float


# TODO create function or signal for when they die


func die():
	# TODO
	pass

func promote():
	if role == GlobalEnums.Role.FIRSTMATE:
		role = GlobalEnums.Role.CAPTAIN
		health *= 1.15
		strength *= 1.15
	else:
		role = GlobalEnums.Role.FIRSTMATE
		health *= 1.075
		strength *= 1.075

func eat(nutrition: float, poison: float):
	satiety = min(nutrition + satiety, maxSatiety)
	recievePoison(poison)

func recievePoison(poison: float):
	health -= int(poison - (poison * constitution))

func _trial(attr: float, success: int, opposition: int) -> bool:
	return attr - opposition >= success

func fight(success: int, opposition: int) -> bool:
	#Lower sanity increases strength, excess sanity does not decrease
	var attr = strength * (1 / min(sanity, 1))
	return _trial(attr, success, opposition)

func fish(success: int, opposition: int) -> bool:
	return _trial(fishing, success, opposition)

func work(success: int, opposition: int) -> bool:
	return _trial(strength * sanity, success, opposition)

func resist(success: int, opposition: int):
	var attr = float(sanity) * (float(satiety) / float(maxSatiety)) * 1.2
	return _trial(attr, success, opposition)

func getFightForSum() -> float:
	#Lower sanity increases strength, excess sanity does not decrease
	return strength * (1 / min(sanity, 1))

func getFishingForSum() -> float:
	return float(fishing)

func getWorkForSum() -> float:
	return strength * sanity

func getResistForSum() -> float:
	return satiety / float(maxSatiety) * 1.2
