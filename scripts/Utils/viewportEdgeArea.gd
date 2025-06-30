extends Area2D
class_name viewPortEdgeArea

@export var widthOfViewport := 0.05
@export var locationRight := false
@export var camera: Camera2D
@onready var collision_shape = $CollisionShape2D
@onready var rect_shape: RectangleShape2D = collision_shape.shape

var lastCameraPos: Vector2
var timer: Timer

func _ready() -> void:
	update_collision_position()
	
func update_collision_position():
	var viewportHeight = get_viewport().get_visible_rect().size.y
	var viewportWidth = get_viewport().get_visible_rect().size.x
	rect_shape.size.y = viewportHeight
	rect_shape.size.x = max(viewportWidth * widthOfViewport, 50 )
	
	if locationRight:
		position.x = camera.position.x + viewportWidth - (rect_shape.size.x / 2)
	else:
		position.x = camera.position.x + (rect_shape.size.x / 2)
		
	position.y = camera.position.y + rect_shape.size.y / 2
