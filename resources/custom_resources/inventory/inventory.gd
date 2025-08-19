extends Resource

class_name Inventory

@export var name: String
@export var money := 0.0
@export var food: Array[InvFood]
@export var resources: Array[InvResource]

func addItems(items: Array[InvItem]) -> void:
	for item in items:
		addItem(item)

func addItem(item: InvItem) -> void:
	if item is InvFood:
		_addItem(item, food)
	elif item is InvResource:
		_addItem(item, resources)
	else:
		printerr('Unable to add item: item is unknown type')

func _addItem(item: InvItem, array: Array):
	var i := array.find_custom(func(it): return item.name == it.name)
	if array[i]: (array[i] as InvItem).count += item.count
	else: array.append(item)

func removeItems(items: Array[InvItem]) -> void:
	for item in items:
		removeItem(item)

func removeItem(item: InvItem) -> void:
	if item is InvFood:
		_removeItem(item, food)
	elif item is InvResource:
		_removeItem(item, resources)
	else:
		printerr('Unable to remove item: item is unknown type')

func _removeItem(item: InvItem, array: Array):
	var i := array.find_custom(func(it): return item.name == it.name)
	if array[i]: (array[i] as InvItem).count -= item.count

	if (array[i] as InvItem).count <= 0: array.remove_at(i)
