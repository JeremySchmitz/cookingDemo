extends Node


var current_scene = null

func _ready():
		var root = get_tree().get_root()
		current_scene = root.get_child(root.get_child_count() - 1)

func gotoResults(
	crewBefore: Array[Crew],
	crewAfter: Array[Crew],
	resultsAttrs: Array[GlobalEnums.CrewAttrs],
	# nextScene: String
	):
	var scene = buildResultsScn(crewBefore, crewAfter, resultsAttrs,
	# nextScene
	)
	goto_scene(scene)
	 	
func goto_scene(path):
	call_deferred("_deferred_goto_scene", path)


func _deferred_goto_scene(path):
	current_scene.free()

	if path is String:
		var s = load(path)
		current_scene = s.instantiate()
	elif path is Node:
		current_scene = path
	else:
		push_error('Unable to load scene')

	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)

func buildResultsScn(
	crewBefore: Array[Crew],
	crewAfter: Array[Crew],
	resultsAttrs: Array[GlobalEnums.CrewAttrs],
	# nextScene: String
	):
	var results: Results = load(Utils.RESULTS_PATH).instantiate()
	results.crewBefore = crewBefore
	results.crewAfter = crewAfter
	results.buildResults(resultsAttrs)
	# results.nextScene = nextScene

	return results
