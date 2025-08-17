extends Node2D
class_name Store
var inventoryRsc = preload("res://Scenes/Inventory/inventory.tscn")

@export var inventory: Inventory
@onready var itemList := %ItemList
var nodeInventory: InventoryScn

func _ready() -> void:
	nodeInventory = inventoryRsc.instantiate()
	nodeInventory.inventory = inventory
	nodeInventory.visible = false
	$ControlFG.add_child(nodeInventory)

	var items = []
	if inventory.resources:
		items.append(inventory.resources[0])
	if inventory.food:
		items.append(inventory.food[0])
		if items.size() && inventory.food.size() > 1:
			items.append(inventory.food[1])

	for item in items:
		var texture = TextureRect.new()
		texture.texture = item.sprite
		texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture.custom_minimum_size = Vector2(200, 200)
		texture.update_minimum_size()
		itemList.add_child(texture)


func _on_inventory_pressed() -> void:
	nodeInventory.visible = true
