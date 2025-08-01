extends Node2D

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


@export var gapH := 60
@export var gapV := 90
@export var maxRow := 13

@onready var totalLabel: Label = $Label_total
@onready var resultsLable = $Label_Results
@onready var npcDeck = $CardDeck_npc

var curTurn := Turns.PC
var gameEnd = false
var total = 0:
	set(val):
		total = val
		totalLabel.text = 'Total: {0}%'.format([val])

var errPC = false
var errNPC = false

func _ready() -> void:
	buildDecks()

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
			_endGame(curTurn)
		else: errors[curTurn] = true
	else:
		if curTurn == Turns.PC:
			total += value
		else: total -= value

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
		_endGame(curTurn)
		return

	if curTurn == Turns.NPC:
		_evaluateNPC()

func _endTurn():
	curTurn = Turns.PC if curTurn == Turns.NPC else Turns.NPC
	_startTurn()

func _endGame(loser: Variant):
	gameEnd = true
	if loser:
		if loser == Turns.PC:
			var sum = (score[Turns.NPC] as Array[float]).reduce(func(prev, val): return prev + val, 0)
			resultsLable.text = 'You lose: price gain {0}'.format([sum])
		else:
			var sum = (score[Turns.PC] as Array[float]).reduce(func(prev, val): return prev + val, 0)
			resultsLable.text = 'You Win: price gain {0}'.format([sum])
	else:
		pass

	resultsLable.visible = true


func _evaluateNPC():
	_clickNPCDeck()

func _clickNPCDeck():
	var event = InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.position = npcDeck.position # Set the position where the click should occur
	get_viewport().push_input(event)


# FOR TESTING
enum DeckColor {BLUE, GREY}

func buildDecks():
	$CardDeck_npc.deckResouce = _buildDeck(DeckColor.GREY)
	$CardDeck_pc.deckResouce = _buildDeck(DeckColor.BLUE)

func _buildDeck(color: DeckColor):
	var res: Resource = _getCardResource(color)

	var resEr: Resource = _getCardResource(color, true)
	var deck: Array[CardResource] = []
	for i in range(0, 10):
		deck.append(res)
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
