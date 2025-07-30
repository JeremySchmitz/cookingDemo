extends Area2D

@onready var collision: CollisionShape2D = $CollisionShape2D

var movement := Vector2(0, 0)
var velocity := Vector2(0, 0)

func _ready():
	monitoring = false
	visible = false

func _unhandled_input(event):
	if (event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_RIGHT
		and event.pressed
	):
		monitoring = true
		visible = true

	if event is InputEventMouseButton and not event.pressed:
		monitoring = false
		visible = false
		
	if monitoring and event is InputEventMouseMotion:
		movement = event.relative
		velocity = event.velocity
		_updatePosition()
		_updateRotation()
		get_viewport().set_input_as_handled()


func _updateRotation():
	rotation = velocity.angle()

func _updatePosition():
	global_position = get_global_mouse_position()

	if monitoring:
		var areas = get_overlapping_areas()
		for area in areas:
			if (area is DraggableArea
				&& area.get_parent() is Food
				&& area.get_parent().get_parent().name != "Organs"):
				area.get_parent().global_position += movement
