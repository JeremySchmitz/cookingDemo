extends Node

const GENERATE_PATH = "res://scripts/Crew/generateCrew.gd"


var boatPosition := Vector2(0, 0)
var targetPosition := Vector2(0, 0)

var _crew: Array[Crew]
var crew: Array[Crew] = []:
	get():
		return _duplicate()
	set(val):
		_crew = _duplicate(val)

func killCrew(mate: Crew, newCrew := crew):
	var i = newCrew.find(mate)
	var promotions: Array[Crew] = []
	mate.kill()
	newCrew.remove_at(i)

	if mate.role == GlobalEnums.Role.CAPTAIN:
		var newCapt := getRole(GlobalEnums.Role.FIRSTMATE)
		newCapt.promote()

		var newFirst := newCapt
		while newFirst != newCapt:
			newFirst = newCrew.pick_random()
		newFirst.promote()

		promotions.append(newCapt)
		promotions.append(newFirst)

	elif mate.role == GlobalEnums.Role.FIRSTMATE:
		var capt := getRole(GlobalEnums.Role.CAPTAIN)

		var newFirst := capt
		while newFirst != capt:
			newFirst = newCrew.pick_random()
		newFirst.promote()

		promotions.append(newFirst)
		
		
func buildCrew(count: int):
	var GENERATE_CREW = load(GENERATE_PATH)
	crew = GENERATE_CREW.new().generate(count)

func getRole(role: GlobalEnums.Role, myCrew := crew) -> Crew:
	if role == GlobalEnums.Role.CREW:
		var crewMates = []
		for member in myCrew:
			if member.role == role: crewMates.append(member)
		return crewMates.pick_random()


	for member in myCrew:
		if member.role == role: return member

	push_error("Crew Has no member with role: ", role)
	return null

func workCrew(low: float, high: float):
	for mate in _crew:
		mate.dailyWork(low, high)


func _duplicate(val: Array[Crew] = _crew) -> Array[Crew]:
	var new: Array[Crew] = []

	for mate: Crew in val:
		new.append(mate.duplicate())

	return new
