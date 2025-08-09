extends Resource
class_name TileNoiseBoundsResource

@export var name: String
@export var tile := TileLookupResource.new()

@export_group('Bounds')
@export_range(-1, 1, .01) var min: float:
	set(val):
		min = val
		if val > max: max = val
		pass
@export_range(-1, 1, .01) var max: float:
	set(val):
		max = val
		if val < min: min = val