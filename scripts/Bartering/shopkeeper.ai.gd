class_name ShopKeeperAI

var Decision = GlobalEnums.Decision
var boldness
var agreableness
var target
var finalChance
var finalTarget

func _init(rsc: ShopKeepResource) -> void:
	boldness = rsc.boldness
	agreableness = rsc.agreableness
	target = rsc.target
	finalChance = rsc.finalChance
	finalTarget = rsc.finalTarget

func evaluateTurn(state: BarterState):
	if !state.error:
		print('no error - CONTINUE')
		return Decision.CONTINUE

	if state.total >= target || state.total + state.stopPenalty >= target:
		print('total > target - OFFER')
		return Decision.OFFER

	if state.total - state.stopPenalty <= finalTarget:
		print('final target - STOP')
		return Decision.STOP

	var errorChance = _checkErrorChance(state)
	print('errorChance: ', errorChance)
	if errorChance > finalChance:
		print('errorChance > finalChance - OFFER')
		return Decision.OFFER
	elif errorChance > boldness:
		print('errorChance > boldness - STOP')
		return Decision.STOP

	print('end CONTINUE')
	return Decision.CONTINUE


func evaluateOffer(offer: float) -> GlobalEnums.Decision:
	if abs(target - offer) < agreableness:
		return Decision.AGREE
	else: return Decision.DECLINE


func _checkErrorChance(state: BarterState) -> float:
	var deck = state.deck.duplicate()
	for val in state.usedCards:
		var i = deck.find(val)
		deck.remove_at(i)

	var errorsLeft = _getErrorsLeft(deck)
	var cardsLeft = deck.size()

	return float(errorsLeft) / cardsLeft

func _getErrorsLeft(deck: Array[float]) -> int:
	return deck.count(-1) - 1