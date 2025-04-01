class_name Food
extends Node2D

@export var polygon2D: Polygon2D
#Should be the draggableArea's Collision Poly
@export var collisionPoly: CollisionPolygon2D
@export var health: Health


@export var maxNutrition: int = 100
@export var maxPoison: int = 30

var nutrition = 0
var poison = maxPoison

var cooked:= GlobalEnums.Cooked.RAW

func _ready() -> void:
	if health:
		health.cookedChanged.connect(_on_health_cooked_changed)
		health.cookedMedium.connect(_on_health_cooked_medium)
		health.cookedWellDone.connect(_on_health_cooked_well)
		health.cookedBurnt.connect(_on_health_cooked_burnt)

func _on_health_cooked_changed(diff: int) -> void:
	if cooked== GlobalEnums.Cooked.BURNT:
		polygon2D.color.r = max(polygon2D.color.r - (diff * .015), .4)
	polygon2D.color.g = max(polygon2D.color.g - (diff * .01), .4)
	polygon2D.color.b = max(polygon2D.color.b - (diff * .01), .4)
	
	setNutrition(diff)


func _on_health_cooked_medium() -> void:
	cooked = GlobalEnums.Cooked.MEDIUM
	
func _on_health_cooked_well() -> void:
	cooked = GlobalEnums.Cooked.WELL
	
func _on_health_cooked_burnt() -> void:
	cooked = GlobalEnums.Cooked.BURNT

func setNutrition(diff: int):
	print('setNutirion')
	var strength
	match cooked:
		GlobalEnums.Cooked.RAW:
			strength = .5
		GlobalEnums.Cooked.MEDIUM:
			strength = 1
		GlobalEnums.Cooked.WELL:
			strength = 2
		GlobalEnums.Cooked.BURNT:
			strength = -1
		_:
			strength = 0
			
	nutrition = min(nutrition + (diff * strength), maxNutrition)
