extends Node2D
enum Mode {CHOP, SLICE, GRAB}

var curMode = Mode.CHOP

func _on_chop_btn_pressed() -> void:
	curMode = Mode.CHOP
	$chopBtn.disabled = true
	$sliceBtn.disabled = false
	$grabBtn.disabled = false
	Signals.modeChange.emit(curMode)
	get_tree().get_root().set_input_as_handled()

func _on_grab_btn_pressed() -> void:
	curMode = Mode.GRAB
	$chopBtn.disabled = false
	$sliceBtn.disabled = false
	$grabBtn.disabled = true
	Signals.modeChange.emit(curMode)
	get_tree().get_root().set_input_as_handled()

func _on_slice_btn_pressed() -> void:
	curMode = Mode.SLICE
	$chopBtn.disabled = false
	$sliceBtn.disabled = true
	$grabBtn.disabled = false
	Signals.modeChange.emit(curMode)
	get_tree().get_root().set_input_as_handled()
