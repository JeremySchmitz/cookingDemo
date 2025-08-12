extends CharacterBody2D
class_name BoatChar


signal moving(val: bool)
signal nextPosition(val: Vector2)

@export var speed := 100.0
@onready var navigation: NavigationAgent2D = $NavigationAgent2D
@onready var maxDist = navigation.target_desired_distance ** 2

var navPathDist := 0.0
var targetReachedBool = false;
var nextPathPos: Vector2
var isMoving = false:
	set(val):
		isMoving = val
		moving.emit(val)

func _ready() -> void:
	isMoving = false

@export var friction = 0.01
@export var acceleration = 0.1


func _input(event: InputEvent) -> void:
	Input.get_vector('left', 'right', 'up', 'down')
	velocity = Input.get_vector('left', 'right', 'up', 'down') * speed

func _physics_process(delta):
	look_at(global_position + velocity.rotated(-PI / 2))
	move_and_slide()

func setTargetPos(pos: Vector2):
	navigation.target_position = pos
	targetReachedBool = false
	isMoving = true