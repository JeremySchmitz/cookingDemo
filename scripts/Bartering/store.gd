extends Node2D
class_name Store
var inventoryRsc = preload("res://Scenes/Inventory/inventory.tscn")
var barterRsc = preload("res://Scenes/Bartering/barter.tscn")

@export var inventory: Inventory
var nodeInventory: InventoryScn
var nodeBarter: BarterScn

func _ready() -> void:
	nodeInventory = inventoryRsc.instantiate()
	nodeInventory.inventory = inventory
	nodeInventory.barter.connect(_on_barter)
	$ControlFG.add_child(nodeInventory)

func _on_inventory_pressed() -> void:
	nodeInventory.visible = true

func _on_barter() -> void:
	%BG_Barter.show()
	nodeInventory.hide()
	nodeBarter = barterRsc.instantiate()
	nodeBarter.endGame.connect(_on_barter_end)
	$ControlFG.add_child(nodeBarter)

func _on_barter_end(discount: int) -> void:
	nodeInventory.discount = discount
	nodeInventory.show()
	%BG_Barter.hide()
	$ControlFG.remove_child(nodeBarter)
	nodeBarter.queue_free()
