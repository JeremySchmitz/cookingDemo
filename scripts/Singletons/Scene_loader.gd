extends Node2D

var loadingScene: LoadingScreen: set = _setLoadingScene
var resultsScene: Results
var current_scene: Node = null
var current_path: String

var buildingResults = false
var results: Array = []


func showResults(
	crewBefore: Array[Crew],
	crewAfter: Array[Crew],
	resultsAttrs: Array[GlobalEnums.CrewAttrs]
	):
	resultsScene.crewBefore = crewBefore
	resultsScene.crewAfter = crewAfter
	resultsScene.buildResults(resultsAttrs)
	resultsScene.show()

func gotoResults(
	crewBefore: Array[Crew],
	crewAfter: Array[Crew],
	resultsAttrs: Array[GlobalEnums.CrewAttrs],
	):
	results.clear()
	results.append_array([crewBefore, crewAfter, resultsAttrs])
	buildingResults = true
	goto_scene(Utils.RESULTS_PATH)
	 	
func goto_scene(path):
	call_deferred("_deferred_goto_scene", path)


func _deferred_goto_scene(path):
	loadingScene.show()

	if path is String:
		loadingScene.load(path)
	elif path is Node:
		current_scene = path
		get_tree().get_root().add_child(current_scene)
		get_tree().set_current_scene(current_scene)
	else:
		push_error('Unable to load scene')

func buildResultsScn(scene):
	scene.crewBefore = results[0]
	scene.crewAfter = results[1]
	scene.buildResults(results[2])

	buildingResults = false

func _setLoadingScene(val: LoadingScreen):
	loadingScene = val
	loadingScene.scene_loaded.connect(_on_scene_loaded)

func _on_scene_loaded(path: String):
	if current_scene: current_scene.queue_free()
	loadingScene.hide()

	var sceneResource = ResourceLoader.load_threaded_get(path)
	current_scene = sceneResource.instantiate()
	current_path = path

	if buildingResults: buildResultsScn(current_scene)

	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)
