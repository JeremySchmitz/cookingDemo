extends Knife

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


var _active = false
var _movement := Vector2(0, 0)
var _velocity := Vector2(0, 0)

func _ready():
	super._ready()
	monitoring = false
	visible = false

func _unhandled_input(event):
	if !_active: return

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
		_movement = event.relative
		_velocity = event.velocity
		_updatePosition()
		_updateRotation()
		get_viewport().set_input_as_handled()


func _updateRotation():
	rotation = _velocity.angle()

func _updatePosition():
	global_position = get_global_mouse_position()

	if monitoring:
		var areas = get_overlapping_areas()
		for area in areas:
			if (area is DraggableArea
				&& area.get_parent() is Food
				&& area.get_parent().get_parent().name != "Organs"):
				area.get_parent().global_position += _movement

func _on_mode_change(m: GlobalEnums.Mode):
	match m:
		GlobalEnums.Mode.SLICE:
			_active = true
			sprite.animation = "slice"
		GlobalEnums.Mode.CHOP:
			_active = true
			sprite.animation = "chop"
		_:
			_active = false