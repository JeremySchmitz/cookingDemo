extends Node2D

const ShopKeeperAI = preload("res://scripts/Bartering/shopkeeper.ai.gd")
enum Turns {PC, NPC}

var errors: Dictionary = {
	Turns.PC: false,
	Turns.NPC: false,
}

var score: Dictionary = {
	Turns.PC: [],
	Turns.NPC: [],
}

var empty: Dictionary = {
	Turns.PC: false,
	Turns.NPC: false,
}

var state: BarterState


@export var gapH := 60
@export var gapV := 90
@export var maxRow := 13
@export var stopPenalty := 5
@export var errorPenalty := 10

@export var keeper: ShopKeepResource

@onready var offer = $Offer
@onready var results = $Results
@onready var totalResultsLabel: Label = $Results/Label_total
@onready var totalLabel: Label = $Label_total
@onready var resultsLabel = $Results/Label_message
@onready var offerResults = $Offer_results
@onready var npcDeck = $CardDeck_npc

var ai: ShopKeeperAI

var turn := 0
var pcOfferTurn := -1
var npcOfferTurn := -1
var curTurn := Turns.PC
var gameEnd = false
var total = 0:
	set(val):
		total = val
		totalLabel.text = 'Total: {0}%'.format([val])
		state.total = val

var errPC = false
var errNPC = false

func _ready() -> void:
	state = BarterState.new()
	state.stopPenalty = stopPenalty
	state.errorPenalty = errorPenalty
	
	buildDecks()
	ai = ShopKeeperAI.new(keeper)

	
func _on_card_deck_pc_clicked(card: Card, size: int) -> void:
	if curTurn == Turns.NPC: return
	_evaluateCard(card.value)
	_moveCard(card, size)
	if !gameEnd: _endTurn()

func _on_card_deck_npc_clicked(card: Card, size: int) -> void:
	if curTurn == Turns.PC: return
	_moveCard(card, size)
	_evaluateCard(card.value)
	if !gameEnd: _endTurn()


func _evaluateCard(value: float):
	if value == -1:
		if errors[curTurn]:
			var playerText
			if curTurn == Turns.PC:
				playerText = "You angered the shopkeeper. He raised the price"
				total += errorPenalty
			else:
				playerText = "The shopkeeper is embarrased. He offers you a great discount"
				total -= errorPenalty
			_endGame(playerText)
		else: errors[curTurn] = true

		if curTurn == Turns.NPC: state.error = true
	else:
		if curTurn == Turns.PC:
			total -= value
		else:
			total += value
			state.usedCards.append(value)

		score[curTurn].append(value)


func _moveCard(card: Card, size):
	card.flip()
	card.reparent($Marker2D)
	var count := $Marker2D.get_child_count()
	var row = count / maxRow
	var x = count % maxRow * gapH + (row % 2 * 0.5 * gapH)
	var y = row * gapV
	card.position = Vector2(x, y)

	if curTurn == Turns.NPC:
		card.rotation += PI

	if size == 1:
		empty[curTurn] = true
	pass


func _startTurn():
	turn += 1
	if empty[curTurn]:
		_endGame("You are both tired and stopped bartering")
		return
	else:
		if curTurn == Turns.NPC:
			_evaluateTurnNPC()
			if npcOfferTurn == turn - 2:
				npcOfferTurn = -1
				state.offeredLastTurn = false
		elif pcOfferTurn == turn - 2:
			pcOfferTurn = -1

	
func _endTurn():
	if curTurn == Turns.NPC:
		curTurn = Turns.PC
	else:
		curTurn = Turns.NPC

	_startTurn()

func _hardStop():
	var playerText = ""
	if curTurn == Turns.PC:
		total += stopPenalty
		playerText = "You"
	else:
		total -= stopPenalty
		playerText = "The shopkeeper"

	var text = "{0} stopped the bartering".format([playerText])
	_endGame(text)

func _endGame(message: String):
	gameEnd = true
	
	resultsLabel.text = message
	var detail = "off" if total <= 0 else "added"
	totalResultsLabel.text = "Final deal: {0}% {1}".format([total, detail])
	results.visible = true
	$Results_hide.visible = true


func _evaluateTurnNPC():
	var response = ai.evaluateTurn(state)

	var action
	match response:
		GlobalEnums.Decision.CONTINUE:
			action = _clickNPCDeck
		GlobalEnums.Decision.OFFER:
			action = _offerNPC
		GlobalEnums.Decision.STOP:
			action = _hardStopNPC

	_executeAIAction(action)

func _executeAIAction(action):
	var time = Timer.new()
	time.wait_time = 1
	time.one_shot = true
	time.timeout.connect(action)
	add_child(time)
	time.start()

func _clickNPCDeck():
	var event = InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.position = npcDeck.position # Set the position where the click should occur
	get_viewport().push_input(event)

func _offerNPC():
	offer.visible = true
	$Offer_hide.visible = true
	npcOfferTurn = turn
	state.offeredLastTurn = true


func _hardStopNPC():
	_hardStop()

func _extendOffer():
	pcOfferTurn = turn
	var response = ai.evaluateOffer(total)
	var action
	match response:
		GlobalEnums.Decision.AGREE:
			action = _endGame.bind("The shopkeeper accepted your offer")
		GlobalEnums.Decision.DECLINE:
			action = _declineOffer
	_executeAIAction(action)

func _declineOffer():
	offerResults.visible = true


func _extendFinalOffer():
	_endGame('You have extended your final offer')


func _setStateDeck(resources: Array[CardResource]):
	var newDeck: Array[float] = []
	for rs: CardResource in resources:
		newDeck.append(rs.value)
	state.deck = newDeck


# FOR TESTING
enum DeckColor {BLUE, GREY}

func buildDecks():
	$CardDeck_npc.deckResouce = _buildDeck(DeckColor.GREY)
	$CardDeck_pc.deckResouce = _buildDeck(DeckColor.BLUE)
	_setStateDeck($CardDeck_npc.deckResouce)

func _buildDeck(color: DeckColor):
	var res: CardResource = _getCardResource(color)

	var resEr: Resource = _getCardResource(color, true)
	var deck: Array[CardResource] = []
	for i in range(0, 10):
		var newRes = res.duplicate()
		newRes.value = 1
		deck.append(newRes)
	for i in range(0, 6):
		var newRes = res.duplicate()
		newRes.value = 2
		deck.append(newRes)
	for i in range(0, 4):
		var newRes = res.duplicate()
		newRes.value = 3
		deck.append(newRes)
	for i in range(0, 2):
		var newRes = res.duplicate()
		newRes.value = 5
		deck.append(newRes)
	for i in range(0, 3):
		deck.append(resEr)

	return deck

func _getCardResource(color: DeckColor, err = false):
	match color:
		DeckColor.BLUE:
			if err:
				return load("res://resources/custom_resources/cards/card_blue_err.tres")
			else:
				return load("res://resources/custom_resources/cards/card_blue.tres")

		DeckColor.GREY:
			if err:
				return load("res://resources/custom_resources/cards/card_grey_err.tres")
			else:
				return load("res://resources/custom_resources/cards/card_grey.tres")

# FOR TESTING END


func _on_offer_reject_pressed() -> void:
	offer.visible = false
	_executeAIAction(_clickNPCDeck)
	$Offer_hide.visible = false

func _on_offer_accept_pressed() -> void:
	offer.visible = false
	$Offer_hide.visible = false
	_endGame("You have accepted the shopkeepers offer")


func _on_extend_offer_pressed() -> void:
	_extendOffer()


func _on_extend_hard_offer_pressed() -> void:
	_hardStop()


func _on_continue_pressed() -> void:
	offerResults.visible = false


func _on_results_hide_pressed() -> void:
	results.visible = !results.visible


func _on_offer_hide_pressed() -> void:
	offer.visible = !offer.visible
