extends Node

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

	save.currentScene = SceneLoader.current_path

	ResourceSaver.save(save, Utils.SAVE_PATH)

func loadGame():
	var file: SavedGame = load(Utils.SAVE_PATH) as SavedGame

	CrewStatus.crew = file.crew.crew as Array[Crew]
	CrewStatus.boatPosition = file.crew.boatPosition
	CrewStatus.inventory = file.crew.inventory

	World.tileSet = file.world.tileSet
	World.ports = file.world.ports

	SceneLoader.goto_scene(file.currentScene)
