extends CharacterBody2D
class_name BoatChar

signal moving(moving: bool)

@export var speed := 100.0
@export var radius := 50.0:
	set(val):
		radius = val
		queue_redraw()

@export var color: Color

var isMoving = false
var prevPos = position
var disabled = false:
	set(val):
		disabled = val
		velocity = Vector2(0, 0)
		isMoving = false

func _process(delta: float) -> void:
	if prevPos != position and !isMoving:
		isMoving = true
		moving.emit(true)
	elif prevPos == position and isMoving:
		moving.emit(false)
		isMoving = false

	prevPos = position
		

func _input(event: InputEvent) -> void:
	if disabled: return
	Input.get_vector('left', 'right', 'up', 'down')
	velocity = Input.get_vector('left', 'right', 'up', 'down') * speed

func _physics_process(delta):
	look_at(global_position + velocity.rotated(-PI / 2))
	move_and_slide()

func _draw() -> void:
	draw_circle(Vector2(0, 0), radius, color, false, 2)

func updateRange(time: float):
	radius = speed * time
