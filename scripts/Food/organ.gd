#@tool
class_name Organ
extends Food

@onready var polygon: PackedVector2Array = collisionPoly.polygon

@export var stats: OrganResource

var parented = true;

func _ready() -> void:
	if !stats: return
	if stats.sprite:
		$Choppable/Sprite2D.texture = stats.sprite
		$Choppable/Sprite2D.scale = stats.spriteScale
	
	if !Engine.is_editor_hint():
		super._ready()
		$Health.medium = stats.medium
		$Health.wellDone = stats.wellDone
		$Health.burnt = stats.burnt
		
		$Nutrition.maxNutrition = stats.maxNutrition
		$Nutrition.nutrition = stats.nutrition
		$Nutrition.rentention = stats.nutritionRentention
		
		$Poison.poisonWhileRaw = stats.poisonWhileRaw
		$Poison.maxPoison = stats.maxPoison
		$Poison.rentention = stats.poisonRentention
		
		shaderSprite = 	get_node("Choppable/Sprite2D")

func _on_draggable_area_dragging() -> void:
	if Engine.is_editor_hint(): return
	if !parented:
		return
#	TODO This needs to be made more surefire 
	reparent(get_parent().get_parent().get_parent())
	parented = false
