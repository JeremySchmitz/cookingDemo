extends Node2D

class_name Encounter

@onready var nameLabel = $Name
@onready var description = $Description
@onready var results = $Results


var currentEncounter: Encounter_Entry:
	get:
		return currentEncounter
	set(val):
		nameLabel.text = currentEncounter.name
		description.text = currentEncounter.desc
		currentEncounter = val

var crew = Array[Crew]


func runEncounter():
	crew = CrewStatus.crew
	_runTrial(currentEncounter)
	
func _runTrial(encounter: Encounter_Entry):
	var target: Crew = _getTrialTarget(encounter.trial_type)

	var success := false
	match encounter.trial_type:
		GlobalEnums.TrialType.SUM:
			success = _trySum(encounter.trial, encounter.trial_requirement)
		_:
			success = _trySingle(target, encounter.trial, encounter.trial_requirement)
	
	target.satiety -= encounter.satiety_consumed()


	if !success:
		var penaltyTarget = _getPenaltyTarget(
			encounter.trial_target,
			target,
			encounter.trial_penalty_count(crew.size())
		)

		_executePenalty(penaltyTarget,
			encounter.trial_penalty,
			encounter.trial_penalty_count(crew.size())
		)

	# TODO theres more to do here

func _getTrialTarget(type: GlobalEnums.TrialType):
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

	return target

func _getPenaltyTarget(type: GlobalEnums.Target, trialTarget: Crew, count: int):
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

	return target

func _trySingle(target: Crew, trialAttr: GlobalEnums.Trial, requirement: int) -> bool:
	return _trial(target, trialAttr) >= requirement

func _trySum(trialAttr: GlobalEnums.Trial, requirement: int) -> bool:
	var sum := 0.0
	for mate in crew:
		sum += _trial(crew, trialAttr)

	return sum >= requirement


func _trial(mate: Crew, trialAttr: GlobalEnums.Trial):
	var attr := 0.0
	match trialAttr:
		GlobalEnums.Trial.SANITY:
			attr = mate.getResistForSum()
		GlobalEnums.Trial.STRENGTH:
			attr = mate.getStrengthForSum()
		GlobalEnums.Trial.FISHING:
			attr = mate.getFishingForSum()
		GlobalEnums.Trial.WORK:
			attr = mate.getWorkForSum()
		GlobalEnums.Trial.COUNT:
			attr = 1

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
			target.poison(count)
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