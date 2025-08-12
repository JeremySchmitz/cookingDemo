extends CharacterBody2D
class_name BoatChar

@export var speed := 100.0


func _input(event: InputEvent) -> void:
	Input.get_vector('left', 'right', 'up', 'down')
	velocity = Input.get_vector('left', 'right', 'up', 'down') * speed

func _physics_process(delta):
	look_at(global_position + velocity.rotated(-PI / 2))
	move_and_slide()
