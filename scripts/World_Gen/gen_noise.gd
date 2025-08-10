extends Resource
class_name GenerativeNoise


@export var noise: Noise
@export var blendMode := GlobalEnums.BlendMode.NONE
@export var gain: float = 0
@export var invert := false
@export var seed: int = 0
@export var ranSeed := false
@export var disable := false
