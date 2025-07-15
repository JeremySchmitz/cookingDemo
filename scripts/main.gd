extends Node2D

const NUM_CREW = 3


func _ready() -> void:
	print('run main')
	Utils.switchScene.connect(_switchScene)
	
	CrewStatus.buildCrew(NUM_CREW)
	loadEncounters()

	var prepScene := ResourceLoader.load("res://Scenes/kitchen.tscn")
	var prepInstance = prepScene.instantiate()
	add_child(prepInstance)
	
	# var prepScene := ResourceLoader.load("res://Scenes/Encounters/encounter.tscn")
	# var prepInstance = prepScene.instantiate()
	# add_child(prepInstance)

	loadEncounters()


func _switchScene(scene: Node2D):
	get_child(0).queue_free()
	add_child(scene)
	
func loadEncounters():
	var loader = EncounterLoader.new()
	loader.load_encounters_from_cfg("res://resources/Configs/events_testing.cfg")
	Utils.setEncounters(loader.encounters)
