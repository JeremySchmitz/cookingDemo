extends Node2D
class_name CustomProgressBar

signal valueChange(v: float)

@onready var progressBar: TextureProgressBar = $TextureProgressBar

@export var minVal := 0.0
@export var maxVal := 100.0: set = _setMax
@export var step := .5
@export var type: GlobalEnums.ProgressTypes

var value := 100.0: set = _setValue

func _ready() -> void:
	progressBar.value = value
	progressBar.min_value = minVal
	progressBar.max_value = maxVal
	progressBar.step = step

func _setValue(val: float):
	value = clamp(val, minVal, maxVal)
	progressBar.value = value

	if value >= maxVal: SignalBus.progressBarFull.emit(type)
	elif value <= minVal: SignalBus.progressBarEmpty.emit(type)

	valueChange.emit(value)

func _setMax(val: float):
	maxVal = val
	progressBar.max_value = val
	if value > maxVal:
		value = maxVal
		progressBar.value = maxVal
