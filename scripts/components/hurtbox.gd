class_name Hurtbox
extends Area2D

signal recievedDamage(damage: float)

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

			if !hitbox.is_connected("frequencyChanged", _updateTimer):
				hitbox.connect("frequencyChanged", _updateTimer.bind(hitbox))

			if !hitbox.is_connected("damageChanged", _updateTimer):
				hitbox.connect("damageChanged", _updateTimer.bind(hitbox))
		else:
			_addDamage(hitbox.damage)


func _on_area_exited(body: Area2D):
	if body is Hitbox:
		var timer: Timer = timers[body.name]
		if timer != null:
			timer.stop()
			timer.queue_free()

		if body.is_connected("frequencyChanged", _updateTimer):
			body.disconnect("frequencyChanged", _updateTimer)

		if body.is_connected("damageChanged", _updateTimer):
			body.disconnect("damageChanged", _updateTimer)


func _buildTimer(hitbox: Hitbox):
	var timer = Timer.new()
	timer.wait_time = hitbox.frequency
	timer.connect("timeout", _addDamage.bind(hitbox.damage))
	timers[hitbox.name] = timer
	add_child(timer)
	timer.start()


func _addDamage(damage: float):
	health.cooked += damage
	recievedDamage.emit(damage)

func _updateTimer(hitbox: Hitbox):
	if hitbox.name in timers:
		var timer: Timer = timers[hitbox.name]
		timer.wait_time = hitbox.frequency
		timer.start()
		
		if timer.is_connected("timeout", _addDamage):
			timer.disconnect("timeout", _addDamage)
			timer.connect("timeout", _addDamage.bind(hitbox.damage))
