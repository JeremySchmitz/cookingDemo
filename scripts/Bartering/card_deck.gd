extends Node2D
class_name CardHand

enum DeckColor {BLUE, GREY}

signal clicked(card: Card, size: int)
signal empty()

const cardScn = preload("res://Scenes/Bartering/card.tscn")
const gap := 0.5

@export var color := DeckColor.BLUE

var deckResouce: Array[CardResource] = []
@onready var cards = $Cards


func _ready() -> void:
	_buildDeck()
	buildDeck()
	setCardPos()

func addCard(cardStat: CardResource):
	var card: Card = cardScn.instantiate()
	card.stats = cardStat
	cards.add_child(card)
	
func setCardPos():
	var deck = cards.get_children()
	for i in range(0, deck.size()):
		var card: Card = deck[i]
		card.position = Vector2(1, 1) * gap * -i


func buildDeck():
	deckResouce.shuffle()
	for card in deckResouce:
		addCard(card)

func _buildDeck():
	var res: Resource = _getCardResource()
	var deck: Array[CardResource] = []
	for i in range(0, 10):
		deck.append(res)
	deckResouce = deck

func _getCardResource():
	match color:
		DeckColor.BLUE:
			print('blue')
			return load("res://resources/custom_resources/cards/card_blue.tres")
		DeckColor.GREY:
			print('grey')
			return load("res://resources/custom_resources/cards/card_grey.tres")


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton
			and event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed
		):
			var children = cards.get_children()
			if children.size():
				var card = children[0]
				clicked.emit(card, children.size())
