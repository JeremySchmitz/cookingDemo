extends Node

var _encounters = []

# Signals
signal startSlice(p: Vector2)
signal endSlice(p: Vector2)
signal modeChange(m: GlobalEnums.Mode)

signal cameraMove()
signal cameraStop()

signal switchScene(s: Node2D)

var RNG = RandomNumberGenerator.new()

func setEncounters(val):
	_encounters = val

func getEncounter(difficulty := GlobalEnums.Difficulty.RAN):
	var i
	if difficulty == GlobalEnums.Difficulty.RAN:
		i = RNG.randi() % (GlobalEnums.Difficulty.size() - 1)
	else:
		i = GlobalEnums.Difficulty.get(difficulty)
	
	var j = RNG.randi() % _encounters[i].size()
	return _encounters[i][j]

func generateIntInRange(minimum: int, maximum: int) -> int:
	return RNG.randi() % (maximum - minimum + 1) + minimum

func generateNormalDistribution(minimum: float, maximum: float):
	var center = (maximum - minimum) / 2 + minimum
	var stddev = (maximum - minimum) / 6.0
	var value = RNG.randfn(center, stddev) # returns a Gaussian random number
	return clamp(value, minimum, maximum)
	
func triangleDistribution(minimum: float, maximum: float, mode: float) -> float:
	var u = RNG.randf() # Uniform random in [0, 1]
	var f = (mode - minimum) / (maximum - minimum)
	if u < f:
		return minimum + sqrt(u * (maximum - minimum) * (mode - minimum))
	else:
		return maximum - sqrt((1 - u) * (maximum - minimum) * (maximum - mode))
