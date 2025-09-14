class_name Hurtbox
extends Area2D

signal recievedDamage(damage: float)

var timers: Dictionary = {}

@export var health: Health
@export var subtractDamage = false

@export var iTime := 1.0
var iTimer: Timer
var invinsible := false;

func _ready():
	_initializeTimer()
	connect("area_entered", _on_area_entered)
	connect("area_exited", _on_area_exited)

func _on_area_entered(body: Area2D):
	if body is Hitbox:
		var hitbox = body as Hitbox

		if body.get_parent().get_parent() is StewPot: return

		_attachTimer(hitbox)


func _on_area_exited(body: Area2D):
	if body is Hitbox:
		if !timers.has(body.name): return

		var timer: Timer = timers[body.name]
		if timer != null:
			timer.stop()
			timer.queue_free()

		if body.is_connected("frequencyChanged", _updateTimer):
			body.disconnect("frequencyChanged", _updateTimer)
			_removeTimer(body)

		if body.is_connected("damageChanged", _updateTimer):
			body.disconnect("damageChanged", _updateTimer)
			_removeTimer(body)

func _attachTimer(hitbox: Hitbox):
	if hitbox.frequency != 0:
		_buildTimer(hitbox)

		if !hitbox.is_connected("frequencyChanged", _updateTimer):
			hitbox.connect("frequencyChanged", _updateTimer.bind(hitbox))

		if !hitbox.is_connected("damageChanged", _updateTimer):
			hitbox.connect("damageChanged", _updateTimer.bind(hitbox))
	else:
		_addDamage(hitbox.damage)

func _buildTimer(hitbox: Hitbox):
	var timer = Timer.new()
	timer.wait_time = hitbox.frequency
	if hitbox.frequency == 0.0: timer.one_shot = true
	timer.connect("timeout", _addDamage.bind(hitbox.damage))
	timers[hitbox.name] = timer
	add_child(timer)
	timer.start()


func _addDamage(damage: float):
	if invinsible: return
	if subtractDamage: health.health -= damage
	else: health.health += damage
	recievedDamage.emit(damage)
	_setInvinsibility(true)

func _updateTimer(hitbox: Hitbox):
	if hitbox.name in timers:
		var timer: Timer = timers[hitbox.name]
		timer.wait_time = hitbox.frequency
		if hitbox.frequency == 0.0: timer.one_shot = true
		timer.start()
		
		if timer.is_connected("timeout", _addDamage):
			timer.disconnect("timeout", _addDamage)
			timer.connect("timeout", _addDamage.bind(hitbox.damage))

func _initializeTimer():
	iTimer = Timer.new()
	iTimer.one_shot = true
	iTimer.wait_time = iTime
	iTimer.connect("timeout", _setInvinsibility.bind(false))
	add_child(iTimer)

func _setInvinsibility(val: bool):
	invinsible = val
	if val: iTimer.start()

func _removeTimer(hitbox: Hitbox):
	if hitbox.name in timers:
		var timer: Timer = timers[hitbox.name]
		timers.erase(hitbox.name)
		timer.queue_free()