class_name Food
extends Node2D

#Should be the draggableArea's Collision Poly
@export var collisionPoly: CollisionPolygon2D
@onready var health = $Health
@onready var hurtbox = $Hurtbox

@export var sprite: Sprite2D
@onready var shader_mat = sprite.material

@export var bitmapSrc := ''
@export var spriteScale := 3.0

	
var cooked := GlobalEnums.Cooked.RAW

func _ready() -> void:
	if health:
		health.cookedChanged.connect(_on_health_cooked_changed)
		health.cookedBurnt.connect(_on_health_cooked_burnt)
	if has_node("Choppable") and $Choppable is Choppable:
		$Choppable.chopped.connect(_on_choppable_choped)
		
	if bitmapSrc:
		_setCollisionFromBM()
		

func _process(delta: float) -> void:
	if find_child("Label"): find_child("Label").text = str(health.cooked)

func _on_health_cooked_changed(val: int) -> void:
	shader_mat.set_shader_parameter("cookVal", float(val))

func _on_health_cooked_burnt() -> void:
	cooked = GlobalEnums.Cooked.BURNT
	shader_mat.set_shader_parameter("isBurnt", true)

func _on_choppable_choped(percent: float) -> void:
	if has_node("Nutrition") and $Nutrition is Nutrition:
		$Nutrition.updateNutritionAfterChop(percent)
	if has_node("Poison") and $Poison is Poison:
		$Poison.updatePoisonAfterChop(percent)
		
func _setCollisionFromBM():
	var poly = _buildCollisionFromBM()
	$DraggableArea/CollisionPolygon2D.polygon = poly
	$Hurtbox/CollisionPolygon2D.polygon = poly.duplicate()
	collisionPoly = $Hurtbox/CollisionPolygon2D
	
func _buildCollisionFromBM() -> PackedVector2Array:
	var bm: BitMap = load(bitmapSrc)
	var size := bm.get_size() * spriteScale
	bm.resize(size)
	var poly := bm.opaque_to_polygons(Rect2(Vector2(), bm.get_size()))[0]

	#center polygon
	var colPoly = []
	for i in range(0, poly.size()):
		colPoly.append(Vector2(poly[i].x - (size.x / 2.0), poly[i].y - (size.y / 2.0)))
	return colPoly
