extends Node2D
enum Mode {CHOP, SLICE, GRAB}

var curMode = Mode.CHOP

func _unhandled_input(_event) -> void:
	match curMode:
		Mode.CHOP:
			#$knifeChop.action(event)
			pass
		Mode.SLICE:
			pass
		Mode.GRAB:
			pass
	
func _on_chop_btn_pressed() -> void:
	curMode = Mode.CHOP
	$chopBtn.disabled = true
	$sliceBtn.disabled = false
	$grabBtn.disabled = false
	$knifeChopper.active = true
	$knifeSlicer.active = false
	get_tree().get_root().set_input_as_handled()

func _on_grab_btn_pressed() -> void:
	curMode = Mode.GRAB
	$chopBtn.disabled = false
	$sliceBtn.disabled = false
	$grabBtn.disabled = true
	$knifeChopper.active = false
	$knifeSlicer.active = false
	get_tree().get_root().set_input_as_handled()

func _on_slice_btn_pressed() -> void:
	curMode = Mode.SLICE
	$chopBtn.disabled = false
	$sliceBtn.disabled = true
	$grabBtn.disabled = false
	$knifeChopper.active = false
	$knifeSlicer.active = true
	get_tree().get_root().set_input_as_handled()
