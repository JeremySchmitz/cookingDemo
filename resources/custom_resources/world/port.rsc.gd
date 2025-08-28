extends Resource
class_name PortResource

const bonusMax = 2
const penaltyMax = 0.5
const bonusStart = -99999999999.9

@export var name: String
@export var position: Vector2
@export var inventory: Inventory
@export_group('Type')
@export var type: GlobalEnums.PortType
@export var _subTypeFood: GlobalEnums.ItemFood
@export var _subTypeResource: GlobalEnums.ItemResource
@export_group('Stats')
@export var priceBonus := bonusStart ## Price Off For Type Items
@export var pricePenalty := bonusStart ## Price Added For Non Type Items
@export var difficulty: GlobalEnums.Difficulty ## If the port is dangerous to visit


## Returns NULL, GlobalEnums.PortType.RESOURCE, GlobalEnums.PortType.FISHING
var subType: Variant:
	get():
		match type:
			GlobalEnums.PortType.RESOURCE:
				return _subTypeResource
			GlobalEnums.PortType.FISHING:
				return _subTypeFood
			_: return null


func _init(dist := 0, maxDist := 0):
	if type == null:
		var i = Utils.RNG.randi_range(0, GlobalEnums.PortType.size() - 1)
		type = GlobalEnums.PortType.get(i)
	if subType == null:
		var en = null
		match type:
			GlobalEnums.PortType.RESOURCE:
				en = _subTypeResource
			GlobalEnums.PortType.FISHING:
				en = _subTypeFood
		if en != null:
			var i = Utils.RNG.randi_range(0, en.size() - 1)
			type = en.get(i)
	
	if priceBonus == bonusStart:
		priceBonus = remap(dist, 0, maxDist, 0, bonusMax)

	if pricePenalty == bonusStart:
		pricePenalty = remap(abs(dist), 0, maxDist, 0, penaltyMax)

	if difficulty == null:
		var base = remap(abs(dist), 0, maxDist, 0, GlobalEnums.Difficulty.size() - 1)
		base = round(base)
		var change = Utils.RNG.randi_range(-1, 1)
		base += change
		base = int(clamp(base, 0, GlobalEnums.Difficulty.size() - 1))
		difficulty = GlobalEnums.Difficulty.get(base)

		
func _getPriceBonus():
	var multiplier
	match difficulty:
		GlobalEnums.Difficulty.EASY:
			multiplier = 1
		GlobalEnums.Difficulty.MEDIUM:
			multiplier = 1.2
		GlobalEnums.Difficulty.HARD:
			multiplier = 1.5
		GlobalEnums.Difficulty.INSANE:
			multiplier = 1.8
		GlobalEnums.Difficulty.COSMIC:
			multiplier = 2.5
		_:
			multiplier = 1

	return priceBonus * multiplier

func _getPricePenalty():
	var multiplier
	match difficulty:
		GlobalEnums.Difficulty.EASY:
			multiplier = 1
		GlobalEnums.Difficulty.MEDIUM:
			multiplier = .9
		GlobalEnums.Difficulty.HARD:
			multiplier = .8
		GlobalEnums.Difficulty.INSANE:
			multiplier = .7
		GlobalEnums.Difficulty.COSMIC:
			multiplier = .5
		_:
			multiplier = 1

	return priceBonus * multiplier


func print():
	var val = '
	name: {0}
	position: {1}
	inventory: {2}
	type: {3}
	_subTypeFood: {4}
	_subTypeResource: {5}
	priceBonus: {6}
	pricePenalty: {7}
	difficulty: {8}
	'.format([
		name,
		position,
		inventory,
		GlobalEnums.PortType.find_key(type),
		GlobalEnums.ItemFood.find_key(_subTypeFood),
		GlobalEnums.ItemResource.find_key(_subTypeResource),
		priceBonus,
		pricePenalty,
		GlobalEnums.Difficulty.find_key(difficulty),
	])

	print('Resource: ', val)
