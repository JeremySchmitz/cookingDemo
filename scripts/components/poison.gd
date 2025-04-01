class_name Poison
extends Node

@export var health: Health
@export var poisonWhileRaw := 0
@export var maxPoison:= 30
@onready var poison:= poisonWhileRaw if poisonWhileRaw else 0 : set = _setPoison


var cooked:= GlobalEnums.Cooked.RAW

func _ready() -> void:
	if health:
		health.cookedMedium.connect(_on_health_cooked_medium)


func _on_health_cooked_medium() -> void:
	cooked = GlobalEnums.Cooked.MEDIUM
	poison = poison - poisonWhileRaw


func _setPoison(val:int) -> void:
	poison = min(val, maxPoison)
