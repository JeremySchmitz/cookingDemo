@tool
extends Node2D


@export_tool_button('Generate') var generate = _generate
@export_tool_button('Clear') var clear = _clear

@export var width := 256
@export var height := 256


@export_group('Noise')
@export var noiseValues: Array[GenerativeNoise]
@export var ranSeed := false

@export_group('Tiles')
@export var tileMap: TileMapLayer
@export var values: GradientTexture1D
@export var tiles: Array[TileNoiseBoundsResource]


var source_id: int = 0
var tileValues: Array

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	_generate()

func _clear():
	tileMap.clear()

func _generate():
	_clear()
	_setTileValues()

	for n in noiseValues:
		if n.ranSeed: n.seed = rng.randi()
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

func _setTileValues():
	tileValues = tiles.map(func(t): return Vector2(t.min, t.max))


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
