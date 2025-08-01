extends Node2D

enum Turns {PC, NPC}

var errors: Dictionary = {
	Turns.PC: false,
	Turns.NPC: false,
}

var empty: Dictionary = {
	Turns.PC: false,
	Turns.NPC: false,
}


@export var gapH := 60
@export var gapV := 90
@export var maxRow := 13

@onready var totalLabel: Label = $Label_total
@onready var npcDeck = $CardDeck_npc

var curTurn := Turns.PC
var total = 0:
	set(val):
		total = val
		totalLabel.text = 'Total: {0}%'.format([val])

var errPC = false
var errNPC = false


func _on_card_deck_pc_clicked(card: Card, size: int) -> void:
	print('pc deck click')
	if curTurn == Turns.NPC: return
	_evaluateCard(card.value)
	_moveCard(card, size)
	_endTurn()

func _on_card_deck_npc_clicked(card: Card, size: int) -> void:
	if curTurn == Turns.PC: return
	_evaluateCard(card.value)
	_moveCard(card, size)
	_endTurn()


func _evaluateCard(value: float):
	print('evaluate: ', curTurn)
	if value == -1:
		if errors[curTurn]:
			_endGame(curTurn)
		else: errors[curTurn] = true
	else:
		total += value

func _moveCard(card: Card, size):
	print('moveCard:', card)
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
	if loser:
		pass
	else:
		pass


func _evaluateNPC():
	_clickNPCDeck()

func _clickNPCDeck():
	var event = InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.position = npcDeck.position # Set the position where the click should occur
	get_viewport().push_input(event)
