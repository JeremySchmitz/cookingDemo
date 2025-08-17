extends Control
class_name CardDeck

enum DeckColor {BLUE, GREY}

signal clicked(card: Card, size: int)
signal empty()

const cardScn = preload("res://Scenes/Bartering/card.tscn")
const gap := 0.5

@export var color := DeckColor.BLUE

var deckResouce: Array[CardResource] = []:
	set(val):
		deckResouce = val
		buildDeck()
		setCardPos()

@onready var cards = %Cards

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

func _getCardResource():
	match color:
		DeckColor.BLUE:
			return load("res://resources/custom_resources/cards/card_blue.tres")
		DeckColor.GREY:
			return load("res://resources/custom_resources/cards/card_grey.tres")

func _on_texture_button_pressed() -> void:
	flipCard()
		
func flipCard():
	var children = cards.get_children()
	if children.size():
		var card = children[0]
		clicked.emit(card, children.size())
