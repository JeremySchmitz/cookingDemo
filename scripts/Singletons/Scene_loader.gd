extends Node2D

signal quitToMenu()

var loadingScene: LoadingScreen: set = _setLoadingScene
var resultsScene: Results
var current_scene: Node = null
var current_path: String

var buildingResults = false
var results: Array = []

func goto_scene(path):
	call_deferred("_deferred_goto_scene", path)


func gotoMainMenu():
	if current_scene: current_scene.queue_free()
	quitToMenu.emit()


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


func _setLoadingScene(val: LoadingScreen):
	loadingScene = val
	loadingScene.scene_loaded.connect(_on_scene_loaded)

func _on_scene_loaded(path: String):
	if current_scene: current_scene.queue_free()
	loadingScene.hide()

	var sceneResource = ResourceLoader.load_threaded_get(path)
	current_scene = sceneResource.instantiate()
	current_path = path

	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)
