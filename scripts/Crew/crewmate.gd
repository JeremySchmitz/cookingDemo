class_name Crew

var role: GlobalEnums.Role
var health: int
#How Susceptable they are poisoned food and how quickly they heal
var constitution: float
var maxSatiation: int
var satiety: int = maxSatiation
var strength: int
var fishing: int
var sanity: float


func eat(nutrition: float, poison: float):
	satiety = min(nutrition + satiety, maxSatiation)
	health -= poison - (poison * constitution)

func _trial(attr: int, success: int, opposition: int) -> bool:
	return attr - opposition > success

func fight(success: int, opposition: int) -> bool:
	#Lower sanity increases strength, excess sanity does not decrease
	var attr = strength * (1 / min(sanity, 1))
	return _trial(strength, success, opposition)

func fish(success: int, opposition: int) -> bool:
	return _trial(fishing, success, opposition)

func work(success: int, opposition: int) -> bool:
	return _trial(strength * sanity, success, opposition)
