class_name FoodChunk
extends Polygon2D

const _minArea = 200
const gapSize = 50

@onready var area2D: FoodChunkArea = get_child(0)
@onready var collider: FoodChunkCollision = area2D.get_child(0)

var rng = RandomNumberGenerator.new()

var _area: float;

var cooking = 0
var _cooked = 0
var cooked: float:
	get:
		return _cooked;
	set(value):
		if value > 200: _cooked = 200;
		else: _cooked = value;
		_setColor()
		
func _ready():
	_getArea()
	if _area < _minArea:
		queue_free()
		
	_configurePosition()

		
func _process(delta):
	if cooking > 0:
		cooked += 50 * delta;

		
	
func _getDirection(ch1: FoodChunk, ch2:FoodChunk):
	var p1 = ch1.position
	var p2 = ch2.position
	var dir = (p2 - p1).normalized()
	print('dir: ' + str(dir))

func _getArea():
	var xCords = []
	var yCords = []
	
	for cord in polygon:
		xCords.append(cord.x)
		yCords.append(cord.y)
		
	var xSum = 0
	var ySum = 0
	
	for i in range(0, xCords.size()):
		var x1 =  xCords[i]
		var x2 =  xCords[i + 1] if i + 1 < xCords.size() else xCords[0]
		var y1 =  yCords[i]
		var y2 =  yCords[i + 1] if i + 1 < yCords.size() else yCords[0]
		
		xSum += x1 * y2
		ySum += y1 * x2
		
	_area = (xSum - ySum) / 2
		
		

func _setColor():
	if cooked <= 100:
		var bg = 1 - (cooked / 100)
		color = Color(1,bg,bg,1)
	else:
		var r = 1 - ((cooked - 100) / 100)
		color = Color(r, 0, 0, 1)


func _configurePosition():
	var ogP = polygon[0]
	var ogPos = position
	position += ogP
	for i in range(0, polygon.size()):
		polygon[i] = polygon[i] - ogP
	collider.position = Vector2(0,0)
	collider.polygon = polygon.duplicate()
	print('collider pos: ' + str(collider.position))
	print('collider poly: ' + str(collider.polygon))
	

func _get(property):
	if property == "name":
		return "FoodChunk"
