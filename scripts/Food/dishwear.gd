extends Node2D

@onready var prevPos = position
var moving = false

func _process(delta: float) -> void:
	if prevPos != position: moving = true
	else: moving = false
	prevPos = position

func _on_area_2d_area_entered(area: Area2D) -> void:
	if moving: return

	var parent = area.get_parent()
	if (parent is Food and
		parent.get_parent().name != 'Organs' and
		parent.get_parent().name != 'VisibleOrgans' and
		parent.get_parent() != self):
		call_deferred("_reparent", parent, self)


func _on_area_2d_area_exited(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent is Food and parent.get_parent() == self:
		call_deferred("_reparent", parent, get_node("/root/Kitchen"))

func _reparent(node: Node2D, parent: Node2D):
	node.reparent(parent)
