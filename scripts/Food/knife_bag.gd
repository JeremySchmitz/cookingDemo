extends Node2D

@onready var chopBtn: KnifeButton = $knife_chop_btn
@onready var sliceBtn: KnifeButton = $knife_slice_btn

var curMode := GlobalEnums.Mode.CHOP

func _on_knife_slice_btn_val_change(val: bool) -> void:
	if val: curMode = GlobalEnums.Mode.SLICE
	else: curMode = GlobalEnums.Mode.GRAB
	chopBtn.value = false
	SignalBus.modeChange.emit(curMode)


func _on_knife_chop_btn_val_change(val: bool) -> void:
	if val: curMode = GlobalEnums.Mode.CHOP
	else: curMode = GlobalEnums.Mode.GRAB
	sliceBtn.value = false
	SignalBus.modeChange.emit(curMode)
