class_name Nutrition
extends Node

signal nutrtionUpdated(nutrition: Nutrition)

@export var health: HealthFood
@export var maxNutrition := 100.0
@export var nutrition := 10.0: set = _setNutrition
@export var rentention: float = .99
@export var nutritiousWhileParented := true

var cooked := GlobalEnums.Cooked.RAW
var parented := true

func _ready() -> void:
	if health:
		health.healthChanged.connect(_on_health_cooked_changed)
		health.cookedMedium.connect(_on_health_cooked_medium)
		health.cookedWellDone.connect(_on_health_cooked_well)
		health.cookedBurnt.connect(_on_health_cooked_burnt)

func getFinalNutrition() -> float:
	if nutritiousWhileParented:
		return nutrition
	else:
		return 0.0 if parented else nutrition

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

func updateNutrition(diff: float, emit = true):
	var strength
	match cooked:
		GlobalEnums.Cooked.RAW:
			strength = .25
		GlobalEnums.Cooked.MEDIUM:
			strength = .5
		GlobalEnums.Cooked.WELL:
			strength = 1
		GlobalEnums.Cooked.BURNT:
			strength = -.2
		_:
			strength = 0
			
	nutrition += diff * strength

	if emit: nutrtionUpdated.emit(self)

func updateNutritionAfterChop(percent: float):
	var newMax = maxNutrition * percent * rentention
	nutrition = nutrition * percent * rentention
	maxNutrition = newMax

func _setNutrition(val: float) -> void:
	nutrition = clamp(val, 0, maxNutrition)
