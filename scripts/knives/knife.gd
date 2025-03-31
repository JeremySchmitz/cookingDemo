class_name Knife
extends Area2D

var inCuttingBoard = false

func _ready():
	connect("area_entered", _on_area_entered)
	connect("area_exited", _on_area_exited)
	Signals.modeChange.connect(_on_mode_change)

func _on_mode_change(m: GlobalEnums.Mode):
	pass

func _on_area_entered(body: Area2D):
	if body.name.to_lower() == 'cuttingboard':
		inCuttingBoard = true
		print('cuttingBoard entered')


func _on_area_exited(body: Area2D):
	if body.name.to_lower() == 'cuttingboard':
		inCuttingBoard = false
		print('cuttingBoard exited')
