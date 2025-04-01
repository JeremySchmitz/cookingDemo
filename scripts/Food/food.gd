class_name Food
extends Node2D

@export var polygon2D: Polygon2D
#Should be the draggableArea's Collision Poly
@export var collisionPoly: CollisionPolygon2D
@export var health: Health

var cooked:= GlobalEnums.Cooked.RAW

func _ready() -> void:
	if health:
		health.cookedChanged.connect(_on_health_cooked_changed)
		health.cookedBurnt.connect(_on_health_cooked_burnt)

func _on_health_cooked_changed(diff: int) -> void:
	if cooked== GlobalEnums.Cooked.BURNT:
		polygon2D.color.r = max(polygon2D.color.r - (diff * .015), .4)
	polygon2D.color.g = max(polygon2D.color.g - (diff * .01), .4)
	polygon2D.color.b = max(polygon2D.color.b - (diff * .01), .4)


func _on_health_cooked_burnt() -> void:
	cooked = GlobalEnums.Cooked.BURNT
