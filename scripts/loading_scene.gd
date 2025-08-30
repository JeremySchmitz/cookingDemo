extends Control
class_name LoadingScreen

signal scene_loaded(path: String)

@onready var progressBar = %ProgressBar
var path: String
var progress_value := 0.0

func load(path_to_load: String):
	progress_value = 0.0
	progressBar.value = 0.0
	path = path_to_load
	ResourceLoader.load_threaded_request(path)

func _process(delta: float):
	if not path: return

	var progress = []
	var status = ResourceLoader.load_threaded_get_status(path, progress)

	if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
		progress_value = progress[0] * 100
		progressBar.value = move_toward(progressBar.value, progress_value, delta * 20)

	if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
		progressBar.value = move_toward(progressBar.value, 100.0, delta * 150)

		if progressBar.value >= 99:
			scene_loaded.emit(path)
