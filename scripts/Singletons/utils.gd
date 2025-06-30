extends Node

# Signals
signal startSlice(p: Vector2)
signal endSlice(p: Vector2)
signal modeChange(m: GlobalEnums.Mode)

signal dinnerTime()

signal cameraMove()
signal cameraStop()

var RNG = RandomNumberGenerator.new()


func generateNormalDistribution(min: float, max: float):
	var center = (max - min) / 2 + min
	var stddev = (max - min) / 6.0
	var value = RNG.randfn(center, stddev) # returns a Gaussian random number
	return clamp(value, min, max)
	
func triangleDistribution(min: float, max: float, mode: float) -> float:
	var u = RNG.randf() # Uniform random in [0, 1]
	var f = (mode - min) / (max - min)
	if u < f:
		return min + sqrt(u * (max - min) * (mode - min))
	else:
		return max - sqrt((1 - u) * (max - min) * (max - mode))
