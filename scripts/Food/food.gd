class_name Food
extends Node2D

@export var polygon2D: Polygon2D
#Should be the draggableArea's Collision Poly
@export var collisionPoly: CollisionPolygon2D
@onready var health = $Health
@onready var hurtbox = $Hurtbox

@export var sprite: Sprite2D
@onready var shader_mat = sprite.material

	
var cooked := GlobalEnums.Cooked.RAW

func _ready() -> void:
	if health:
		health.cookedChanged.connect(_on_health_cooked_changed)
		health.cookedBurnt.connect(_on_health_cooked_burnt)
	if has_node("Choppable") and $Choppable is Choppable:
		$Choppable.chopped.connect(_on_choppable_choped)

func _process(delta: float) -> void:
	if $Label: $Label.text = str(health.cooked)

func _on_health_cooked_changed(val: int) -> void:
	shader_mat.set_shader_parameter("cookVal", float(val))

func _on_health_cooked_burnt() -> void:
	cooked = GlobalEnums.Cooked.BURNT
	shader_mat.set_shader_parameter("isBurnt", true)

func _on_choppable_choped(percent: float) -> void:
	if has_node("Nutrition") and $Nutrition is Nutrition:
		$Nutrition.updateNutritionAfterChop(percent)
	if has_node("Poison") and $Poison is Poison:
		$Poison.updatePoisonAfterChop(percent)
