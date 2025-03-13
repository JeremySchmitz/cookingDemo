class_name Hurtbox
extends Area2D

signal recievedDamage(damage: int)

var timers: Dictionary = {}

@export var health: Health

func _ready():
	connect("area_entered", _on_area_entered)
	connect("area_exited", _on_area_exited)


func _on_area_entered(body: Area2D):
	if body is Hitbox:
		var hitbox = body as Hitbox
		if hitbox.frequency != 0:
			_buildTimer(hitbox)
		else:
			_addDamage(hitbox.damage)


func _on_area_exited(body: Area2D):
	if body is Hitbox:
		var timer: Timer = timers[body.name]
		if timer != null:
			timer.stop()
			timer.queue_free()


func _buildTimer(hitbox: Hitbox):
	var timer = Timer.new()
	timer.wait_time = hitbox.frequency
	timer.connect("timeout", _addDamage.bind(hitbox.damage))
	timers[hitbox.name] = timer
	add_child(timer)
	timer.start()


func _addDamage(damage: int):
	health.cooked += damage
	recievedDamage.emit(damage)
