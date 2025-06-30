extends Node2D

const NUM_CREW = 3


func _ready() -> void:
	CrewStatus.buildCrew(NUM_CREW)
	var prepScene := ResourceLoader.load("res://Scenes/world.tscn")
	var prepInstance = prepScene.instantiate() 
	add_child(prepInstance)
