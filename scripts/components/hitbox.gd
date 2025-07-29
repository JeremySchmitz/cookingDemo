class_name Hitbox
extends Area2D

signal damageChanged()
signal frequencyChanged()

@export var damage: float = 5:
	set(value):
		damage = value
		damageChanged.emit()
#Damage Frequency in seconds
@export var frequency: float = 0.3:
	set(value):
		frequency = value
		frequencyChanged.emit()
