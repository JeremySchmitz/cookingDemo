extends Node


func save_game():
	var save = SavedGame.new()

	var crewStatus = CrewResource.new()
	crewStatus.crew = CrewStatus.crew
	crewStatus.boatPosition = CrewStatus.boatPosition
	crewStatus.inventory = CrewStatus.inventory


	save.crew = crewStatus
	# var file: SavedGame = FileAccess.open("user://savegame.data", FileAccess.WRITE) as S
	pass


func load_game():
	var file: SavedGame = load("user://savegame.data") as SavedGame
	pass