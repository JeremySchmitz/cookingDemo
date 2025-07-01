extends Node2D

const NUM_CREW = 3


func _ready() -> void:
	Utils.switchScene.connect(_switchScene)
	
	CrewStatus.buildCrew(NUM_CREW)
	var prepScene := ResourceLoader.load("res://Scenes/world.tscn")
	var prepInstance = prepScene.instantiate() 
	add_child(prepInstance)


func _switchScene(scene: Node2D):
	get_child(0).queue_free()
	add_child(scene)
