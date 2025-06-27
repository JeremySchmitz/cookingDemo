class_name Nutrition
extends Node


@export var health: Health
@export var maxNutrition:= 100
@export var nutrition:= 10 : set = _setNutrition
@export var rentention: float = .99

var cooked:= GlobalEnums.Cooked.RAW

func _ready() -> void:
	if health:
		health.cookedChanged.connect(_on_health_cooked_changed)
		health.cookedMedium.connect(_on_health_cooked_medium)
		health.cookedWellDone.connect(_on_health_cooked_well)
		health.cookedBurnt.connect(_on_health_cooked_burnt)

func _on_health_cooked_changed(diff: int) -> void:
	updateNutrition(diff)


func _on_health_cooked_medium() -> void:
	cooked = GlobalEnums.Cooked.MEDIUM
	nutrition = 0.5 * maxNutrition
	
func _on_health_cooked_well() -> void:
	cooked = GlobalEnums.Cooked.WELL
	nutrition = 0.8 * maxNutrition
	
func _on_health_cooked_burnt() -> void:
	cooked = GlobalEnums.Cooked.BURNT
	nutrition = 0.8 * maxNutrition

func updateNutrition(diff: int):
	var strength
	match cooked:
		GlobalEnums.Cooked.RAW:
			strength = .25
		GlobalEnums.Cooked.MEDIUM:
			strength = .5
		GlobalEnums.Cooked.WELL:
			strength = 1
		GlobalEnums.Cooked.BURNT:
			strength = -.75
		_:
			strength = 0
			
	nutrition = nutrition + (diff * strength)

func updateNutritionAfterChop(percent: float):
	var newMax = maxNutrition * percent * rentention
	nutrition = nutrition * percent * rentention
	maxNutrition = newMax

func _setNutrition(val: int) -> void:
	nutrition = min(val, maxNutrition)
