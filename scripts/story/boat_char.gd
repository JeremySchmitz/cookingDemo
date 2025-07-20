extends CharacterBody2D


signal moving(val: bool)
signal nextPosition(val: Vector2)

const speed := 100.0
@onready var navigation: NavigationAgent2D = $NavigationAgent2D
@onready var maxDist = navigation.target_desired_distance ** 2

var navPath: PackedVector2Array = []
var targetReachedBool = false;
var nextPathPos: Vector2
var isMoving = false:
	set(val):
		isMoving = val
		moving.emit(val)

func _ready() -> void:
	isMoving = false


func _physics_process(delta: float) -> void:
	if !targetReachedBool:
		var direction = (navigation.get_next_path_position() - global_position).normalized()
		translate(direction * delta * speed)
		checkNexPathPos()

func setTargetPos(pos: Vector2):
	navigation.target_position = pos
	targetReachedBool = false
	isMoving = true
	nextPosition.emit(global_position)

func _on_navigation_agent_2d_target_reached() -> void:
	targetReachedBool = true;
	isMoving = false


func checkNexPathPos():
	var pos := navigation.get_next_path_position()
	if nextPathPos != pos:
		nextPosition.emit(nextPathPos)
		nextPathPos = pos
