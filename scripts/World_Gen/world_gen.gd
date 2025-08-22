@tool
extends Node2D

const maxWanders = 1000

@export_tool_button('Generate') var generate = _generate
@export_tool_button('Generate Land') var generateLand = _generateLand
@export_tool_button('Generate Ports') var generatePorts = _generatePorts
@export_tool_button('Clear') var clear = _clear
@export_tool_button('Clear Ports') var clearPorts = _clearPorts

@export var width := 256
@export var height := 256

@export var randSeed = false;
@export var seed = 0

@export_group('Ports')
@export var numPorts := 10
@export var firstPortPos := Vector2(128, 128)
@export var portAtlasCords := Vector2i(0, 0)
@export var searchRadius := 50
@export var wanderDistance := 100
@export var minDistance := 50
@export var portSeed = 1
@export var randPortSeed = false;

@export_group('Noise')
@export var noiseValues: Array[GenerativeNoise]
@export var ranSeed := false

@export_group('Tiles')
@export var tileMap: TileMapLayer
@export var values: GradientTexture1D
@export var tiles: Array[TileNoiseBoundsResource]


var source_id: int = 0
var tileValues: Array

var rng: RandomNumberGenerator
var portPositions: Array


func _ready() -> void:
	_setTileValues()
	if !Engine.is_editor_hint():
		rng = Utils.RNG
		_generate()
	else:
		rng = RandomNumberGenerator.new()
		if randSeed: seed = randi()
		rng.seed = seed


func _clear():
	tileMap.clear()

func _clearPorts():
	if has_node("PortsNode"):
		var portsNode = get_node("PortsNode")
		for child in portsNode.get_children():
			portsNode.remove_child(child)

func _generate():
	_generateLand()
	_generatePorts()

	
func _setTileValues():
	tileValues = tiles.map(func(t): return Vector2(t.min, t.max))


func _generatePorts():
	if randSeed || randPortSeed:
		portSeed = rng.randi()
	rng.seed = portSeed
	var ports: Array[Vector2] = []
	var startPoint = firstPortPos
	var distance = minDistance * minDistance

	var check = 0
	while ports.size() < numPorts && check < maxWanders:
		var pos: Array[Vector2] = search_circle(startPoint, searchRadius)
		if pos.size() == 1:
			var tooClose = false
			for port in ports:
				tooClose = port.distance_squared_to(pos[0]) < distance
				if tooClose: break
			if !tooClose: ports.append(pos[0])

		startPoint = wander(startPoint)
		check += 1

	var portsNode = _getPortsParent()

	if Engine.is_editor_hint():
		_buildToolPorts(ports, portsNode)
	else:
		_buildScenePorts(ports, portsNode)
		_buildPortResources(portsNode)
	portPositions = ports.map(func(m): return Vector2(m.x * tileMap.tile_set.tile_size.x, m.y * tileMap.tile_set.tile_size.y) / 2) as Array[Vector2]

func _getPortsParent():
	var portsNode
	if has_node("PortsNode"):
		portsNode = get_node("PortsNode")
		for child in portsNode.get_children():
			portsNode.remove_child(child)
	else:
		portsNode = Node2D.new()
		portsNode.name = "PortsNode"
		add_child(portsNode)
		portsNode.owner = self

	return portsNode

func _buildScenePorts(ports: Array[Vector2], parent: Node2D):
	var portScene = preload("res://Scenes/Story/port.tscn")

	for p in ports:
		var port = portScene.instantiate()
		parent.add_child(port)
		port.position = Vector2(p.x * tileMap.tile_set.tile_size.x, p.y * tileMap.tile_set.tile_size.y) / 2

		# TODO Update
		var portName = ""
		for i in 3:
			var letter = char("A".unicode_at(0) + randi() % 26)
			portName += letter
		port.labelName = portName

func _buildPortResources(portsNode: Node2D):
	print('_buildPortResources: ', portsNode.get_child_count())
	var ports = portsNode.get_children().filter(func(p): return is_instance_of(p, Port))
	if !ports.size(): return
	print('ports:', ports.size())

	var maxDistance = Vector2(0, 0).distance_to(Vector2(width, height))
	for port: Port in ports:
		var dist = port.position.distance_to(ports[0].position)
		var rsc = PortResource.new(dist, maxDistance)
		rsc.name = port.labelName
		rsc.position = port.position

		port.resource = rsc
		# rsc.print()


func _buildToolPorts(ports: Array[Vector2], parent: Node2D):
	for p in ports:
		var label1 = Label.new()
		label1.name = 'Label'
		var label2 = Label.new()
		label2.name = 'Label'
		var info = Info.new()
		info.add_child(label2)
		info.name = 'Info'
		var sprite1 = Sprite2D.new()
		sprite1.texture = load("res://resources/Sprites/Travel/circle_bg.tres")
		var sprite2 = Sprite2D.new()
		sprite2.texture = load("res://resources/Sprites/Travel/dock.png")
		var port = Port.new()
		port.add_child(label1)
		port.add_child(info)
		port.add_child(sprite1)
		port.add_child(sprite2)
		port.scale = Vector2(2, 2)
		port.name = "port_01"
		parent.add_child(port)

		
		label1.owner = port
		label2.owner = info
		port.owner = self
		port.position = Vector2(p.x * tileMap.tile_set.tile_size.x, p.y * tileMap.tile_set.tile_size.y) / 2


func wander(pos: Vector2):
	var angle = rng.randf_range(0, PI * 2)
	var offsetAngle = Vector2(1, 0).rotated(angle).normalized()
	var newPos = round(pos + (offsetAngle * wanderDistance))

	if newPos.x > width || newPos.x < 0 || newPos.y > height || newPos.y < 0:
		newPos = Vector2(rng.randi_range(0, width), rng.randi_range(0, height))

	return newPos

func search_circle(center: Vector2, radius: int) -> Array[Vector2]:
	var results: Array[Vector2] = []
	for i in range(-radius, radius + 1):
		for j in range(-radius, radius + 1):
			var pos = center + Vector2(i, j)
			var tile = tileMap.get_cell_atlas_coords(pos)
			if tile == portAtlasCords:
				return [pos]
			else: results.append(pos)
	return results

func _generateLand():
	for n in noiseValues:
		if randSeed || n.ranSeed: n.seed = rng.randi()
		n.noise.seed = n.seed

	for x in range(width):
		for y in range(height):
			var noiseVal = _addNoiseValues(x, y)
			for i in range(tileValues.size()):
				var min = tileValues[i].x
				var max = tileValues[i].y
				if noiseVal >= min && noiseVal <= max:
					var tile = tiles[i].tile
					tileMap.set_cell(Vector2(x, y), tile.source_id, tile.atlas_coordinates)
					break


func _addNoiseValues(x: int, y: int):
	var value: float = 1.0
	for i in range(noiseValues.size()):
		if !noiseValues[i].disable:
			value = _getNoiseValue(i, x, y, value)

	return value

func _getNoiseValue(i: int, x: int, y: int, prev := 1.0) -> float:
	var n: GenerativeNoise = noiseValues[i]
	var value: float = n.noise.get_noise_2d(x, y)

	value = remap(value, -0.5, 0.5, -1, 1)
	value += n.gain
	if n.invert: value *= -1
	value = _blend(prev, value, n.blendMode)

	return value


func _blend(prev: float, new: float, mode: GlobalEnums.BlendMode):
	var value
	match mode:
		GlobalEnums.BlendMode.NONE:
			value = new
		GlobalEnums.BlendMode.MULTIPLY:
			value = blend_multiply(prev, new)
		GlobalEnums.BlendMode.DARKEN:
			value = blend_darken(prev, new)
		GlobalEnums.BlendMode.OVERLAY:
			value = blend_overlay(prev, new)
		GlobalEnums.BlendMode.SCREEN:
			value = blend_screen(prev, new)
		GlobalEnums.BlendMode.COLOR_BURN:
			value = blend_color_burn(prev, new)
	return clamp(value, -1, 1)
# Blend Modes
# Multiply
func blend_multiply(base: float, blend: float) -> float:
	return base * blend

# Darken
func blend_darken(base: float, blend: float) -> float:
	return min(base, blend)


# Overlay
func blend_overlay(base: float, blend: float) -> float:
	return overlay_channel(base, blend)

func overlay_channel(b, s):
		return 2 * b * s if b < 0.5 else 1 - 2 * (1 - b) * (1 - s)

# Screen
func blend_screen(base: float, blend: float) -> float:
	return 1 - (1 - base) * (1 - blend)

# Color Burn
func blend_color_burn(base: float, blend: float) -> float:
	return burn_channel(base, blend)

func burn_channel(b, s):
		if s == 0:
			return 0
		return max(0, 1 - (1 - b) / s)
