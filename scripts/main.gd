extends Node2D

const NUM_CREW = 3


func _ready() -> void:
	SceneLoader.loadingScene = %LoadingScene
	SceneLoader.quitToMenu.connect(onQuitToMenu)
	CrewStatus.buildCrew(NUM_CREW)
	loadEncounters()

func loadEncounters():
	var loader = EncounterLoader.new()
	loader.load_encounters_from_cfg("res://resources/Configs/events_testing.cfg")
	Utils.setEncounters(loader.encounters)

func onQuitToMenu():
	%MainMenu.show()
