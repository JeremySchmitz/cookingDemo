extends Resource
class_name OrganResource

@export var sprite: Texture
@export var spriteScale:= Vector2(1,1)

@export_subgroup("Health")
@export var medium: int = 50
@export var wellDone: int = 75
@export var burnt: int = 100

@export_subgroup("Nutrition")
@export var maxNutrition := 100.0
@export var nutrition := 10.0
@export var nutritionRentention: float = .99

@export_subgroup("Poison")
@export var poisonWhileRaw := 0
@export var maxPoison := 30
@export var poisonRentention: float = 1
