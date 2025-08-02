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

@export var keeper: ShopKeepResource

@onready var offer = $Offer
@onready var results = $Results
@onready var totalResultsLabel: Label = $Results/Label_total
@onready var totalLabel: Label = $Label_total
@onready var resultsLabel = $Results/Label_message
@onready var offerResults = $Offer_results
@onready var npcDeck = $CardDeck_npc

var ai: ShopKeeperAI


var curTurn := Turns.PC
var gameEnd = false
var offerExtended = false
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
	
	buildDecks()
	ai = ShopKeeperAI.new(keeper)

	
func _on_card_deck_pc_clicked(card: Card, size: int) -> void:
	if curTurn == Turns.NPC || gameEnd: return
	_evaluateCard(card.value)
	_moveCard(card, size)
	_endTurn()

func _on_card_deck_npc_clicked(card: Card, size: int) -> void:
	if curTurn == Turns.PC || gameEnd: return
	_evaluateCard(card.value)
	_moveCard(card, size)
	_endTurn()


func _evaluateCard(value: float):
	if value == -1:
		if errors[curTurn]:
			var playerText
			if curTurn == Turns.PC:
				playerText = "You angered the shopkeeper. He raised the price"
			else: playerText = "The shopkeeper is embarrased. He offers you a great discount"
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
	if empty[curTurn]:
		_endGame("You are both tired and stopped bartering")
		return

	if curTurn == Turns.NPC:
		_evaluateTurnNPC()

func _endTurn():
	curTurn = Turns.PC if curTurn == Turns.NPC else Turns.NPC
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
	totalResultsLabel.text = "Final offer {0}".format([total])
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


func _hardStopNPC():
	_hardStop()

func _extendOffer():
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
	for i in range(0, 10):
		var newRes = res.duplicate()
		newRes.value = 2
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
	if offerExtended:
		offer.visible = false

	_executeAIAction(_clickNPCDeck)


func _on_offer_accept_pressed() -> void:
	if offerExtended:
		offer.visible = false
		_endGame("You have accepted the shopkeepers offer")


func _on_extend_offer_pressed() -> void:
	_extendOffer()


func _on_extend_hard_offer_pressed() -> void:
	_hardStop()


func _on_continue_pressed() -> void:
	offerResults.visible = false


func _on_button_pressed() -> void:
	results.visible = !results.visible
