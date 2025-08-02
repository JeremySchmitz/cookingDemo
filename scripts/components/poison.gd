class_name Poison
extends Node


@export var health: Health
@export var poisonWhileRaw := 0.0
@export var maxPoison := 30.0
@onready var poison := poisonWhileRaw:
	set(val):
		poison = min(val, maxPoison)
	
@export var rentention: float = 1


var cooked := GlobalEnums.Cooked.RAW

func _ready() -> void:
	if health:
		health.cookedMedium.connect(_on_health_cooked_medium)


func _on_health_cooked_medium() -> void:
	cooked = GlobalEnums.Cooked.MEDIUM
	poison = poison - poisonWhileRaw


func updatePoisonAfterChop(percent: float):
	var newMax = maxPoison * percent * rentention
	poison = poison * percent * rentention
	maxPoison = newMax
