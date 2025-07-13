class_name Encounter_Entry

var name: String = ""
var desc: String = ""
var difficulty: GlobalEnums.Difficulty
var trial: GlobalEnums.Trial
var trial_type: GlobalEnums.TrialType
var trial_requirement: int = 0
var trial_penalty: GlobalEnums.TrialPenalty
func trial_penalty_count(size: int) -> int: return size
var trial_target: GlobalEnums.Target
func trial_target_count(size: int) -> int: return size
func satiety_consumed() -> int: return -1
var reward: GlobalEnums.Reward
var reward_type = ""
var reward_count = 0
var reward_target: GlobalEnums.Target
func pass_text(rewardVar) -> String: return rewardVar
var pass_vars: Array[String] = []
func fail_text(fail_var) -> String: return fail_var
var fail_vars: Array[String] = []

func _init(data = {}):
    for key in data.keys():
        self.set(key, data[key])