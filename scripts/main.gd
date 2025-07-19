extends Node2D

const NUM_CREW = 3


func _ready() -> void:
	print('run main')
	Utils.switchScene.connect(_switchScene)
	
	CrewStatus.buildCrew(NUM_CREW)
	loadEncounters()

	var boat_scene = preload("res://Scenes/Story/boat_travel.tscn").instantiate()
	add_child(boat_scene)
	boat_scene.start_boat_travel([Vector2(100, 100), Vector2(400, 120), Vector2(700, 200)], ["Port Sunrise", "Port Twilight"])

	# var prepScene := ResourceLoader.load("res://Scenes/kitchen.tscn")
	# var prepInstance = prepScene.instantiate()
	# add_child(prepInstance)
	
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
