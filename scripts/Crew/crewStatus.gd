extends Node

const GENERATE_PATH = "res://scripts/Crew/generateCrew.gd"


var crew: Array[Crew] = [] : 
	get():
		return crew.duplicate(true)
	set(val):
		crew = val.duplicate(true)


func buildCrew(count: int):
	const GENERATE_CREW = preload(GENERATE_PATH)
	crew = GENERATE_CREW.new().generate(count)
