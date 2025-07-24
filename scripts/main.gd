extends Node2D

const NUM_CREW = 3


func _ready() -> void:
	CrewStatus.buildCrew(NUM_CREW)
	loadEncounters()

	var boat_scene = preload("res://Scenes/Story/boat_travel.tscn").instantiate()
	add_child(boat_scene)

	# var prepScene := ResourceLoader.load("res://Scenes/kitchen.tscn")
	# var prepInstance = prepScene.instantiate()
	# add_child(prepInstance)
	
	# var encounterScn := ResourceLoader.load("res://Scenes/Encounters/encounter.tscn")
	# var encounterInstance = encounterScn.instantiate()
	# add_child(encounterInstance)

	loadEncounters()


func loadEncounters():
	var loader = EncounterLoader.new()
	loader.load_encounters_from_cfg("res://resources/Configs/events_testing.cfg")
	Utils.setEncounters(loader.encounters)
