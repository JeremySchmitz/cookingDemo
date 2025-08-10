class_name Health
extends Node

signal healthChanged(diff: int)
signal healthZero()

@export var health: float = 0.0: set = setHealth
@export var min := 0.0
@export var max := 100.0
@export var healthBar: CustomProgressBar

func setHealth(val: float):
	if val != health:
		var newHealth = clamp(val, min, max)
		var dif = abs(val - newHealth)
		health = newHealth
		healthChanged.emit(dif)
		
		if health == 0: healthZero.emit()
		if healthBar: healthBar.value = health
