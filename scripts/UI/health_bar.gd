extends Node2D
class_name HealthBar

@export var mask: BitMap
@onready var progressBar: TextureProgressBar = $TextureProgressBar

var value := 100.0:
	set(val):
		value = val
		progressBar.value = val

func _ready() -> void:
	progressBar.value = value
