class_name Food
extends Node2D

@export var polygon2D: Polygon2D
#Should be the draggableArea's Collision Poly
@export var collisionPoly: CollisionPolygon2D
@export var health: Health

var cookedBurnt = false

func _ready() -> void:
	if health:
		health.cookedChanged.connect(_on_health_cooked_changed)
		health.cookedBurnt.connect(_on_health_cooked_burnt)

func _on_health_cooked_changed(diff: int) -> void:
	print('cookedChanged')
	if cookedBurnt:
		polygon2D.color.r -= min(diff * .005, 40)
	polygon2D.color.g -= min(diff * .01, 40)
	polygon2D.color.b -= min(diff * .01, 40)


func _on_health_cooked_burnt() -> void:
	cookedBurnt = true
