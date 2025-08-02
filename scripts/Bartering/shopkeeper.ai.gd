class_name ShopKeeperAI

var Decision = GlobalEnums.Decision
var boldness
var agreableness
var target
var finalChance
var negTarget

func _init(rsc: ShopKeepResource) -> void:
	boldness = rsc.boldness
	agreableness = rsc.agreableness
	target = rsc.target
	finalChance = rsc.finalChance
	negTarget = rsc.negTarget

func evaluateTurn(state: BarterState):
	#  Continue drawing if there is no chance of failing
	if !state.error:
		print('no error - CONTINUE')
		return Decision.CONTINUE

	var errorChance = _checkErrorChance(state)
	# Dont offer if it offered last turn
	if !state.offeredLastTurn:
		# If its reached its target goal offer
		if state.total >= target:
			print('total >= target - OFFER')
			return Decision.OFFER

		# If it drawing an error would put it ovver its neg target offer
		if state.total - state.errorPenalty <= negTarget:
			print('final target - OFFER')
			return Decision.OFFER

		# If chance of error is to high offer
		if errorChance > boldness:
			print('errorChance > boldness - OFFER')
			return Decision.OFFER
	
	# If reached target even with penalty stop
	if state.total - state.stopPenalty >= target:
			print('total - penalty > target - OFFER')
			return Decision.STOP


	# If chance of error is to high stop
	if errorChance > finalChance:
			print('errorChance > finalChance - STOP')
			return Decision.STOP

	# otherwise draw
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