extends Control
class_name InventoryScn

enum InventoryMode {STORE, PLAYER}

signal barter()
signal leave()

@export var inventory: Inventory
@export var shopInventory: Inventory
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
@onready var nodeListCart: ItemList = %ListCart
# Selection
@onready var nodePanelSelection := %PanelSelection
@onready var nodeSelectedTexture := %SelectedTexture
@onready var nodeSelectedName := %SelectedName
@onready var nodeSelectedDescription := %SelectedDescription
@onready var nodePanelAddButtons := %PanelAddButtons
@onready var nodeSubtractButton := %ButtonSubtract
# Main List
@onready var nodePanelMainList := %PanelMainList
@onready var nodeLabelMainList := %LabelMainList
@onready var nodeListMain: ItemList = %ListMain
# Secondary List
@onready var nodePanelSecondaryList := %PanelSecondaryList
@onready var nodeLabelSecondaryList := %LabelSecondaryList
@onready var nodeListSecondary: ItemList = %ListSecondary
# Buttons
@onready var nodeButtonBuy := %ButtonBuy
@onready var nodeButtonBarter := %ButtonBarter
@onready var nodeButtonLeave := %ButtonLeave


var listMain: Array = []
var listSecondary: Array = []

var selectedList: Array
var selectedNodeList: ItemList
var selectedItem: InvItem: set = _setSelectedItem

var cart: Array[InvItem] = []
var cost := 0
var discount := 0:
	set(val):
		discount = val
		_updateCartLabel()

var bartered = false:
	set(val):
		bartered = val
		_updateButtons()

func _ready() -> void:
	generateTestArrays()

	nodeMoneyCount.text = str(inventory.money)
	if mode == InventoryMode.PLAYER:
		nodeCharacterName.text = inventory.name

		nodePanelCart.visible = false
		nodePanelAddButtons.visible = false

		if inventory.food:
			listMain = inventory.food
			nodeLabelMainList.text = 'Food'
			_addItemsToList(inventory.food, nodeListMain)

		if inventory.resources:
			listSecondary = inventory.resources
			nodeLabelSecondaryList.text = 'Resources'
			_addItemsToList(inventory.resources, nodeListSecondary)
	
	else:
		nodeCharacterName.text = shopInventory.name
		nodeLabelMainList.text = 'Wares'
		_setUpShopLists()

		
func _addItemsToList(list: Array, nodeList: ItemList):
	for item: InvItem in list:
		print('addItemToList:', item.name, item.count)
		nodeList.add_item(_getItemText(item), item.sprite)

func _on_list_main_item_selected(index: int) -> void:
	_selectItem(index, nodeListMain)

func _on_list_secondary_item_selected(index: int) -> void:
	_selectItem(index, nodeListSecondary)

	
func _on_list_cart_item_selected(index: int) -> void:
	_selectItem(index, nodeListCart)

func _selectItem(i: int, list: ItemList):
	if list == nodeListMain:
		nodeListSecondary.deselect_all()
		nodeListCart.deselect_all()
		if selectedList != listMain: selectedList = listMain
		if selectedNodeList != nodeListMain: selectedNodeList = nodeListMain
		selectedItem = listMain[i]
	elif list == nodeListSecondary:
		nodeListMain.deselect_all()
		nodeListCart.deselect_all()
		if selectedList != listSecondary: selectedList = listSecondary
		if selectedNodeList != nodeListSecondary: selectedNodeList = nodeListSecondary
		selectedItem = listSecondary[i]
	else:
		nodeListMain.deselect_all()
		nodeListSecondary.deselect_all()
		if selectedList != cart: selectedList = cart
		if selectedNodeList != nodeListCart: selectedNodeList = nodeListCart
		selectedItem = cart[i]

func _setSelectedItem(val: InvItem):
	selectedItem = val
	nodeSelectedName.text = val.name
	nodeSelectedDescription.text = val.description
	nodeSelectedTexture.texture = val.sprite

	var i = _selectedItemInList(cart)
	nodeSubtractButton.disabled = i == -1


func _on_button_add_pressed() -> void:
	_updateList(cart, nodeListCart)
	_updateList(listMain, nodeListMain, true)

	nodeSubtractButton.disabled = false

	_updateCartLabel()
	_updateButtons()

func _on_button_subtract_pressed() -> void:
	_updateList(cart, nodeListCart, true)
	_updateList(listMain, nodeListMain)
	
	nodeSubtractButton.disabled = _selectedItemInList(cart) == -1

	_updateCartLabel()
	_updateButtons()

func _getItemText(item: InvItem):
	return '{0} ${1} ({2})'.format([item.name, item.cost, item.count])

func _selectedItemInList(list: Array) -> int:
	return list.find_custom(func(item): return item.name == selectedItem.name)

func _updateList(list: Array, nodeList: ItemList, subtract = false):
	var i = _selectedItemInList(list)
	if i == -1:
		if subtract: return

		var newItem: InvItem = selectedItem.duplicate(true)
		newItem.count = 1
		list.append(newItem)
		_addItemsToList([newItem], nodeList)
		nodeList.set_item_text(-1, _getItemText(list[-1]))
	else:
		var item = list[i]
		item.count += 1 if !subtract else -1
		if subtract && item.count == 0:
			list.remove_at(i)
			nodeList.remove_item(i)
		else:
			nodeList.set_item_text(i, _getItemText(item))


func _updatedSelectedCount(subtract = false):
	selectedItem.count += 1 if !subtract else -1
	var i = selectedList.find(selectedItem)
	if i == -1:
		push_error('Unable to find selected item in list')
		return
		
	if selectedItem.count == 0:
		selectedList.remove_at(i)
		selectedNodeList.remove_item(i)
	else:
		selectedNodeList.set_item_text(i, _getItemText(selectedItem))

	
func _delectItem():
	selectedItem = null
	selectedList = []
	selectedNodeList.deselect_all()
	selectedNodeList = null

func _updateCartLabel():
	cost = 0
	for item in cart:
		cost += item.cost * item.count
	var discountText = ''
	if discount:
		var d = (100 - discount) / 100.0
		cost = round(cost * d)
		var add = 'Off ' if discount > 0 else 'Added'
		discountText = ' - {0}% {1}'.format([abs(discount), add])
	nodeLabelCart.text = 'Cart: ${0}{1}'.format([cost, discountText])

func _updateButtons():
	nodeButtonBuy.disabled = cart.size() == 0 || cost > inventory.money
	nodeButtonBarter.disabled = bartered || cart.size() == 0

func _on_button_leave_pressed() -> void:
	leave.emit()

func _on_button_barter_pressed() -> void:
	bartered = true
	barter.emit()

func _on_button_buy_pressed() -> void:
	inventory.addItems(cart)
	inventory.money -= cost

	shopInventory.money += cost
	cart.clear()
	nodeListCart.clear()
	nodeListMain.clear()
	nodeListSecondary.clear()

	_setUpShopLists()
		
	nodeMoneyCount.text = str(inventory.money)
	_updateButtons()
	_updateCartLabel()


func _setUpShopLists():
	listMain = []
	listSecondary = []
	if shopInventory.food:
		listMain.append_array(shopInventory.food)
		_addItemsToList(shopInventory.food, nodeListMain)
	if shopInventory.resources:
		listMain.append_array(shopInventory.resources)
		_addItemsToList(shopInventory.resources, nodeListMain)

	
	nodeLabelSecondaryList.text = 'Inventory'
	if inventory.food:
		listSecondary.append_array(inventory.food)
		_addItemsToList(inventory.food, nodeListSecondary)
	if inventory.resources:
		listSecondary.append_array(inventory.resources)
		_addItemsToList(inventory.resources, nodeListSecondary)


# FOR TEST
func generateTestArrays():
	var food01 = InvFood.new()
	food01.sprite = load("res://resources/Sprites/Crab/crab_body.png")
	food01.count = 3
	food01.cost = 30
	var food02 = InvFood.new()
	food02.sprite = load("res://resources/Sprites/PufferFish_02/pufferFiish02_Body.png")
	food02.count = 2
	food02.cost = 100
	var resource01 = InvResource.new()
	resource01.sprite = load("res://resources/Sprites/Travel/dock.png")
	resource01.count = 20
	resource01.cost = 12
	
	inventory.food = [food01, food02]
	inventory.resources = [resource01]
	
	var food03 = InvFood.new()
	food03.sprite = load("res://resources/Sprites/Crab/crab_body.png")
	food03.count = 6
	food03.cost = 80
	var food04 = InvFood.new()
	food04.sprite = load("res://resources/Sprites/PufferFish_02/pufferFiish02_Body.png")
	food04.cost = 96
	food04.count = 7
	var resource02 = InvResource.new()
	resource02.sprite = load("res://resources/Sprites/Travel/dock.png")
	resource02.count = 50
	resource02.cost = 20

	shopInventory.food = [food03, food04]
	shopInventory.resources = [resource02]
