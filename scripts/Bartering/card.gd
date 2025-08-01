extends Node2D
class_name Card

@onready var back := $Back
@onready var front := $Front

@export var stats: CardResource
var value := 1.0
var faceFront := false

func _ready() -> void:
	if stats:
		$Back/Sprite2D_back.texture = stats.back
		$Front/Sprite2D_front.texture = stats.front
		value = stats.value
		if value != -1:
			$Front/text_front.text = str(value)
		else:
			$Front/text_front.visible = false

func flip():
	if faceFront:
		print('face front')
		back.visible = true
		front.visible = false
	else:
		back.visible = false
		front.visible = true
		
	faceFront = !faceFront
