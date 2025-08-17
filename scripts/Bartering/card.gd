extends Control
class_name Card

@onready var back := %Back
@onready var front := %Front
@onready var frontTexture := %Front_texture
@onready var text := %Text

@export var stats: CardResource
var value := 1.0
var faceFront := false

func _ready() -> void:
	if stats:
		back.texture = stats.back
		frontTexture.texture = stats.front
		value = stats.value
		if value != -1:
			text.text = str(value)
		else:
			text.visible = false

func flip():
	if faceFront:
		back.visible = true
		front.visible = false
	else:
		back.visible = false
		front.visible = true
		
	faceFront = !faceFront
