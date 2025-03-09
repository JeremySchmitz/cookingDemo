class_name FoodChunkCollision

extends CollisionPolygon2D

func _ready():
	var area2D = get_parent()
	var chunk = area2D.get_parent()
	polygon = chunk.polygon
