extends Node

class_name EncounterLoader

var encounters = {
	GlobalEnums.Difficulty.EASY: [],
	GlobalEnums.Difficulty.MEDIUM: [],
	GlobalEnums.Difficulty.HARD: [],
	GlobalEnums.Difficulty.INSANE: [],
	GlobalEnums.Difficulty.COSMIC: [],
	GlobalEnums.Difficulty.STORY: []
}

func load_encounters_from_cfg(path):
	var cfg = ConfigFile.new()
	var err = cfg.load(path)

	if err != OK:
		push_error("Failed to load config file: %s" % path)
		return
		
	for section in cfg.get_sections():
		# Only process encounter sections
		if section.begins_with("encounter"):
			var data = {}
			for key in cfg.get_section_keys(section):
				data[key] = cfg.get_value(section, key)
			var encounter = Encounter.new(massageData(data))
			
			var diff = encounter.difficulty
			if encounters.has(diff):
				encounters[diff].append(encounter)
			else:
				encounters[diff] = [encounter]
		
func massageData(data):
	data["difficulty"] = massageDifficulty(data["difficulty"]);

	data["trial"] = massageTrial(data["trial"]);
	data["trial_type"] = massageTrialType(data["trial_type"]);
	# requirement doesnt need massage
	data["trial_penalty"] = massageTrialPenalty(data["trial_penalty"]);
	data["trial_penalty_count"] = massageCount(data["trial_penalty_count"], "penalty");
	data["trial_target"] = massageTarget(data["trial_target"]);
	data["trial_target_count"] = massageCount(data["trial_target_count"], "target");

	data["satiety_consumed"] = massageSatiety(data["satiety_consumed"]);

	data["reward"] = massageReward(data["reward"]);
	data["reward_type"] = massageRewardType(data["reward_type"]);
	# reward count doesnt need massage
	data["reward_target"] = massageTarget(data["reward_target"]);

	data["pass_text"] = massagePassText(data["pass_text"]);
	data["fail_text"] = massageFailText(data["fail_text"]);


	return data;

func massageDifficulty(difficulty: String) -> GlobalEnums.Difficulty:
	return GlobalEnums.Difficulty.get(difficulty)

func massageTarget(target: String) -> GlobalEnums.Target:
	return GlobalEnums.Target.get(target)

# Trial
func massageTrial(trial: String) -> GlobalEnums.Trial:
	return GlobalEnums.Trial.get(trial)

func massageTrialType(type: String) -> GlobalEnums.TrialType:
	print('trial type:', type)
	return GlobalEnums.TrialType.get(type)

func massageTrialPenalty(penalty: String) -> GlobalEnums.TrialPenalty:
	return GlobalEnums.TrialPenalty.get(penalty)


func massageCount(count, attr: String):
	if typeof(count) is int:
		return func(_x): return count
		
	var regex = RegEx.new()
	regex.compile(r"\bRANGE")

	if regex.search(count):
		var split = count.split("_")
		if split.size() != 3:
			push_error('Unable to read %s count - RANGE has incorrect size: %s'.format(attr, count))
		var start = split[1]
		var end = split[2]

		return func(_x): return Utils.generateIntInRange(start, end)

	var percent = 0
	match count:
		"QUART":
			percent = .25
		"THIRD":
			percent = .33
		"HALF":
			percent = .50
		"MOST":
			percent = .75
		"ALL":
			percent = 1
		"NONE":
			percent = 0
		_:
			push_error('Unable to read %s count - invalid value: %s'.format(attr, count))

	return func(size: int): return floor(size * percent);


# satiety
func massageSatiety(count):
	if typeof(count) is int:
		return func(): return count
		
	var regex = RegEx.new()
	regex.compile(r"\bRANGE")

	if regex.search(count):
		var split = count.split("_")
		if split.size() != 3:
			push_error('Unable to read satiety count - RANGE has incorrect size:', count)
		var start = split[1]
		var end = split[2]

		return func(): return Utils.generateIntInRange(start, end)
		
	push_error('Enable to read satiety count - invalid value', count)

		
#reward
func massageReward(reward: String) -> GlobalEnums.Reward:
	return GlobalEnums.Reward.get(reward)

func massageRewardType(reward: String):
	# TODO
	return reward

func massagePassText(passText: String):
	return func(reward: Array): return passText % reward

func massageFailText(failText: String):
	return func(target): return failText % target

# Example usage:
# load_encounters_from_cfg("res://resources/Configs/events.cfg")
# print(encounters["MEDIUM"])
