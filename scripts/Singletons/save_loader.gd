extends Node

const SAVE_PATH = "user://savegame.tres"

func saveGame():
	var save = SavedGame.new()

	var crew = CrewResource.new()
	crew.crew = CrewStatus.crew
	crew.boatPosition = CrewStatus.boatPosition
	crew.inventory = CrewStatus.inventory

	var world = WorldResource.new()
	world.tileSet = World.tileSet
	world.ports = World.ports

	save.crew = crew
	save.world = world

	ResourceSaver.save(save, SAVE_PATH)

func loadGame():
	var file: SavedGame = load(SAVE_PATH) as SavedGame

	CrewStatus.crew = file.crew.crew as Array[Crew]
	CrewStatus.boatPosition = file.crew.boatPosition
	CrewStatus.inventory = file.crew.inventory

	World.tileSet = file.world.tileSet
	World.ports = file.world.ports
