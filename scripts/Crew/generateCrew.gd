extends Node

const minHealth:int = 60
const maxHealth:int = 120
const meanHealth:int = 100

const minConstitution:float = 0.0
const maxConstitution:float = 1.0
const meanConstitution:float = 0.2

const minStrength:int = 40
const maxStrength:int = 200
const meanStrength:int = 100

const minFishing:int = 60
const maxFishing:int = 200
const meanFishing:int = 100

const minSanity:int = 50
const maxSanity:int = 100
const meanSanity:int = 80

const minSatiety:float = 0
const maxSatiety:float = 1.2
const meanSatiety:float = .9


func generate(count: int, crewOnly := false) -> Array[Crew]:
	var crew: Array[Crew] = []
	for i in range(0, count):
		crew.append(_buildCrewMember(_getRole(crewOnly, i)))
	return crew

func _getRole(crewOnly: bool, i: int) -> GlobalEnums.Role:
	var role: GlobalEnums.Role
	if crewOnly:
		role = GlobalEnums.Role.CREW
	else:
		if i == 0:
			role = GlobalEnums.Role.CAPTAIN
		elif i == 1:
			role = GlobalEnums.Role.FIRSTMATE
		else:
			role = GlobalEnums.Role.CREW
	return role

func _buildCrewMember(role: GlobalEnums.Role) -> Crew:
	var member:= Crew.new()
	member.role = role
	member.name = _generateName()
	member.health = floor(Utils.triangleDistribution(minHealth, maxHealth, meanHealth))
	member.constitution = floor(Utils.triangleDistribution(minConstitution, maxConstitution, meanConstitution))
	member.strength = floor(Utils.triangleDistribution(minStrength, maxStrength, meanStrength))
	member.fishing = floor(Utils.triangleDistribution(minFishing, maxFishing, meanFishing))
	member.sanity = floor(Utils.triangleDistribution(minSanity, maxSanity, meanSanity))
	member.maxSatiety = floor(Utils.triangleDistribution(minSatiety, maxSatiety, meanSatiety))
	
	return member


func _generateName():
	var name = ""
	for i in 3:
		var letter = char("A".unicode_at(0) + randi() % 26)
		name += letter
	return name
