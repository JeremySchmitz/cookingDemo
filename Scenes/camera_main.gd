extends Camera2D

var moving = false;
@onready var cam: Camera2D = self
@onready var lastPos: Vector2 = cam.get_screen_center_position()


func _process(delta: float) -> void:
	var curPos = cam.get_screen_center_position()
	if !moving && curPos != lastPos:
		print('moving')
		Utils.cameraMove.emit()
		moving = true
	elif moving && curPos == lastPos:
		print('stoped')
		Utils.cameraStop.emit()
		moving = false
	
	lastPos = curPos
