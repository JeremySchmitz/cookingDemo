#@tool
class_name Organ
extends Food

@export var stats: OrganResource

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
		$Nutrition.nutritiousWhileParented = stats.nutritiousWhileParented
		
		$Poison.poisonWhileRaw = stats.poisonWhileRaw
		$Poison.maxPoison = stats.maxPoison
		$Poison.rentention = stats.poisonRentention
		
		shaderSprite = get_node("Choppable/Sprite2D")
