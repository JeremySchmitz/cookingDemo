extends CenterContainer
class_name InventoryScn
enum InventoryMode {STORE, PLAYER}
@export var inventory: Inventory
@export var mode: InventoryMode = InventoryMode.PLAYER
@export var showCart = false
@export var showSecondList = false
# Titles
@onready var nodeCharacterName := %CharacterName
@onready var nodeMoneyTexture := %MoneyTexture
@onready var nodeMoneyCount := %MoneyCount
# Cart
@onready var nodePanelCart := %PanelCart
@onready var nodeLabelCart := %LabelCart
@onready var nodeListCart := %ListCart
# Selection
@onready var nodePanelSelection := %PanelSelection
@onready var nodeSelectedTexture := %SelectedTexture
@onready var nodeSelectedName := %SelectedName
@onready var nodeSelectedDescription := %SelectedDescription
# Main List
@onready var nodePanelMainList := %PanelMainList
@onready var nodeLabelMainList := %LabelMainList
@onready var nodeListMain := %ListMain
# Secondary List
@onready var nodePanelSecondaryList := %PanelSecondaryList
@onready var nodeLabelSecondaryList := %LabelSecondaryList
@onready var nodeListSecondary := %ListSecondary


var listMain: Array
var listSecondary: Array

var selectedList: Array
var selectedItem: InvItem: set = _setSelectedItem

func _ready() -> void:
	nodeCharacterName.text = inventory.name
	nodeMoneyCount.text = str(inventory.money)

	if mode == InventoryMode.PLAYER:
		nodePanelCart.visible = false
	
		if inventory.food:
			listMain = inventory.food
			nodeLabelMainList.text = 'Food'
			_addItemsToList(inventory.food, nodeListMain)

		if inventory.resources:
			listSecondary = inventory.resources
			nodeLabelSecondaryList.text = 'Resources'
			_addItemsToList(inventory.resources, nodeListSecondary)


func _addItemsToList(list: Array, nodeList: ItemList):
	for item: InvItem in list:
		var itemName = '{1} ({0})'.format([item.count, item.name])
		nodeList.add_item(itemName, item.sprite)

func _on_list_main_item_selected(index: int) -> void:
	_selectItem(index, nodeListMain)

func _on_list_secondary_item_selected(index: int) -> void:
	_selectItem(index, nodeListSecondary)
	
func _selectItem(i: int, list: ItemList):
	if list == nodeListMain:
		nodeListSecondary.deselect_all()
		if selectedList != listMain: selectedList = listMain
		selectedItem = listMain[i]
	else:
		nodeListMain.deselect_all()
		if selectedList != listSecondary: selectedList = listSecondary
		selectedItem = listSecondary[i]

func _setSelectedItem(val: InvItem):
	nodeSelectedName.text = val.name
	nodeSelectedDescription.text = val.description
	nodeSelectedTexture.texture = val.sprite
