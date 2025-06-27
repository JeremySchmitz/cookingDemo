class_name Food
extends Node2D

@export var polygon2D: Polygon2D
#Should be the draggableArea's Collision Poly
@export var collisionPoly: CollisionPolygon2D
@export var health: Health

@export var sprite: Sprite2D
@onready var shader_mat = sprite.material

	
var cooked:= GlobalEnums.Cooked.RAW

func _ready() -> void:
	if health:
		health.cookedChanged.connect(_on_health_cooked_changed)
		health.cookedBurnt.connect(_on_health_cooked_burnt)

func _on_health_cooked_changed(val: int) -> void:
	shader_mat.set_shader_parameter("cookVal", float(val))

func _on_health_cooked_burnt() -> void:
	cooked = GlobalEnums.Cooked.BURNT
	shader_mat.set_shader_parameter("isBurnt", true)
