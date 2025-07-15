extends Node2D

const NUM_CREW = 3


func _ready() -> void:
	print('run main')
	Utils.switchScene.connect(_switchScene)
	
	CrewStatus.buildCrew(NUM_CREW)
	loadEncounters()

	#var prepScene := ResourceLoader.load("res://Scenes/world.tscn")
	#var prepInstance = prepScene.instantiate()
	#add_child(prepInstance)
	
	var prepScene := ResourceLoader.load("res://Scenes/Encounters/encounter.tscn")
	var prepInstance = prepScene.instantiate()
	add_child(prepInstance)

	loadEncounters()


func _switchScene(scene: Node2D):
	get_child(0).queue_free()
	add_child(scene)
	
func loadEncounters():
	var loader = EncounterLoader.new()
	loader.load_encounters_from_cfg("res://resources/Configs/events_testing.cfg")
	Utils.setEncounters(loader.encounters)
	print('EASY: ', loader.encounters[GlobalEnums.Difficulty.EASY].size())
	print('MEDIUM: ', loader.encounters[GlobalEnums.Difficulty.MEDIUM].size())
	print('HARD: ', loader.encounters[GlobalEnums.Difficulty.HARD].size())
	print('INSANE: ', loader.encounters[GlobalEnums.Difficulty.INSANE].size())
	print('COSMIC: ', loader.encounters[GlobalEnums.Difficulty.COSMIC].size())
