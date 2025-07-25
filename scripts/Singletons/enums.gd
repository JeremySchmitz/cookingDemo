class_name GlobalEnums

# Scenes
enum Scenes {Kitchen, Results, Encounter, BoatTravel}


#Cooking
enum Mode {CHOP, SLICE, GRAB}
enum Cooked {RAW, MEDIUM, WELL, BURNT}

#Crew
enum Role {CAPTAIN, FIRSTMATE, CREW}
enum CrewStatus {HEALTHY, SICK, FATIGUED, INSANE}
enum CrewAttrs {HEALTH, CONSTITUTION, STRENGTH, FISHING, SANITY, HUNGER}

#Encounters
enum Difficulty {EASY, MEDIUM, HARD, INSANE, COSMIC, STORY, RAN}
enum Trial {SANITY, STRENGTH, FISHING, WORK, COUNT}
enum TrialType {MAX_RAN, MAX_CAPT, MAX_FIRST_M, SUM}
enum TrialPenalty {DEATH, POISON, CONSTITUTION, SATIETY, SANITY, HEALTH, FISHING, MUTINY, FOOD}

enum Target {NONE, RANDOM, CAPT, FIRST_M, TARGET}

enum Reward {FOOD, SANITY, STRENGTH, FISHING, COUNT, GOLD, NONE}
