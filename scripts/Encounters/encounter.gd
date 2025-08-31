extends Control
class_name EncounterScene

const RESULTS_SCENE = preload("res://Scenes/food/results.tscn")

const RESULTS_ATTRS: Array[GlobalEnums.CrewAttrs] = [
		GlobalEnums.CrewAttrs.HEALTH,
		GlobalEnums.CrewAttrs.HUNGER,
		GlobalEnums.CrewAttrs.CONSTITUTION,
		GlobalEnums.CrewAttrs.STRENGTH,
		GlobalEnums.CrewAttrs.FISHING,
		GlobalEnums.CrewAttrs.SANITY
		]

@export var resultsScene: Results

@onready var nameLabel = %Name
@onready var description = %Description
@onready var results = %Results
@onready var contBtn = %ContBtn

var encounterRun:
	set(val):
		encounterRun = val
		contBtn.disabled = !val


var crewBefore: Array[Crew] = []
var crewAfter: Array[Crew] = []

var currentEncounter: Encounter_Entry:
	get:
		return currentEncounter
	set(val):
		currentEncounter = val
		nameLabel.text = val.name
		description.text = val.desc
		results.text = ""
		encounterRun = false

var crew: Array[Crew] = CrewStatus.crew


func _ready() -> void:
	currentEncounter = Utils.getEncounter()

func loadEncounter():
	currentEncounter = Utils.getEncounter()

func runEncounter():
	crew = CrewStatus.crew
	_runTrial(currentEncounter)
	
func _runTrial(encounter: Encounter_Entry):
	crewBefore = crew
	print('run trial')
	var target: Crew = _getTrialTarget(encounter.trial_type)

	var success := false
	match encounter.trial_type:
		GlobalEnums.TrialType.SUM:
			success = _trySum(encounter.trial, encounter.trial_requirement)
			
			for mate in crew:
				mate.satiety -= encounter.satiety_consumed()
		_:
			success = _trySingle(target, encounter.trial, encounter.trial_requirement)
			target.satiety -= encounter.satiety_consumed()


	if !success:
		# var penaltyTarget = _getPenaltyTarget(
		# 	encounter.trial_target,
		# 	target,
		# 	encounter.trial_penalty_count(crew.size())
		# )
		# _executePenalty(penaltyTarget,
		# 	encounter.trial_penalty,
		# 	encounter.trial_penalty_count(crew.size())
		# )
		# TODO Update
		var vars = []
		for entry in encounter.fail_vars:
			vars.append(encounter[entry])
		print('FAIL fail_vars: ', encounter.fail_vars)
		print('FAIL vars: ', vars)

		results.text = encounter.fail_text.format(vars)

	else:
		# TODO Update
		var vars = []
		for entry in encounter.pass_vars:
			vars.append(encounter[entry])
		print('PASS pass_vars: ', encounter.pass_vars)
		print('PASS vars: ', vars)

		results.text = encounter.pass_text.format(vars)


	# TODO theres more to do here

	CrewStatus.crew = crew
	SaveLoader.saveGame()

func _getTrialTarget(type: GlobalEnums.TrialType):
	print('_getTrialTarget trial type: ', type)
	var target: Crew
	match type:
		GlobalEnums.TrialType.MAX_RAN:
			target = crew.pick_random()
		GlobalEnums.TrialType.MAX_CAPT:
			target = CrewStatus.getRole(GlobalEnums.Role.CAPTAIN, crew)
		GlobalEnums.TrialType.MAX_FIRST_M:
			target = CrewStatus.getRole(GlobalEnums.Role.FIRSTMATE, crew)
		_:
			target = null

	print('_getTrialTarget trial target: ', target)
	return target

func _getPenaltyTarget(type: GlobalEnums.Target, trialTarget: Crew, count: int):
	print('_getPenaltyTarget trial type: ', type)
	var target
	match type:
		GlobalEnums.Target.RANDOM:
			target = []
			for i in range(0, count):
				target.add(crew.pick_random())
		GlobalEnums.Target.CAPT:
			target = CrewStatus.getRole(GlobalEnums.Role.CAPTAIN, crew)
		GlobalEnums.Target.FIRST_M:
			target = CrewStatus.getRole(GlobalEnums.Role.FIRSTMATE, crew)
		GlobalEnums.Target.TARGET:
			target = trialTarget
		_:
			target = null

	print('_getPenaltyTarget target: ', target)
	return target

func _trySingle(target: Crew, trialAttr: GlobalEnums.Trial, requirement: int) -> bool:
	print('_trySingle')
	return _trial(target, trialAttr) >= requirement

func _trySum(trialAttr: GlobalEnums.Trial, requirement: int) -> bool:
	print('_trySum')
	var sum := 0.0
	for mate in crew:
		sum += _trial(mate, trialAttr)
	print('_trySum sum: ', sum, " requirement: ", requirement)

	return sum >= requirement


func _trial(mate: Crew, trialAttr: GlobalEnums.Trial):
	print('_trial mate:', mate)
	print('_trial mate:', mate.name)

	var attr := 0.0
	match trialAttr:
		GlobalEnums.Trial.SANITY:
			attr = mate.getResistForSum()
		GlobalEnums.Trial.STRENGTH:
			attr = mate.getFightForSum()
		GlobalEnums.Trial.FISHING:
			attr = mate.getFishingForSum()
		GlobalEnums.Trial.WORK:
			attr = mate.getWorkForSum()
		GlobalEnums.Trial.COUNT:
			attr = 1

	print('_trial attr:', attr)
	return attr

func _executePenalty(target, penalty: GlobalEnums.TrialPenalty, count: int):
	if penalty == GlobalEnums.TrialPenalty.MUTINY:
		# TODO
		pass
	elif penalty == GlobalEnums.TrialPenalty.FOOD:
		# TODO pass
		pass
	else:
		if target is Crew:
			_penalty(target, penalty, count)
		elif target is Array[Crew]:
			for mate in target:
				_penalty(mate, penalty, count)
		

func _penalty(target: Crew, penalty: GlobalEnums.TrialPenalty, count: int):
	match penalty:
		GlobalEnums.TrialPenalty.DEATH:
			CrewStatus.killCrew(target)
		GlobalEnums.TrialPenalty.POISON:
			target.recievePoison(count)
		GlobalEnums.TrialPenalty.CONSTITUTION:
			target.constitution -= count
		GlobalEnums.TrialPenalty.SATIETY:
			target.satiety -= count
		GlobalEnums.TrialPenalty.SANITY:
			target.sanity -= count
		GlobalEnums.TrialPenalty.HEALTH:
			target.health -= count
		GlobalEnums.TrialPenalty.FISHING:
			target.fishing -= count


func _on_replay_btn_pressed() -> void:
	currentEncounter = Utils.getEncounter()


func _on_cont_btn_pressed() -> void:
	buildResults()
	resultsScene.buildResults(RESULTS_ATTRS)
	hide()
	resultsScene.show()


func _on_run_pressed() -> void:
	runEncounter()
	encounterRun = true


func buildResults():
	resultsScene.crewBefore = crewBefore
	resultsScene.crewAfter = crew
	resultsScene.buildResults(RESULTS_ATTRS)
