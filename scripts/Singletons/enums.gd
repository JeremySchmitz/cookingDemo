class_name GlobalEnums

# Scenes
enum Scenes {Kitchen, Results, Encounter, BoatTravel}

enum ProgressTypes {HEALTH, STAMINA}

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


#Barter
enum Decision {CONTINUE, OFFER, STOP, AGREE, DECLINE}
enum Mood {HAPPY, NEUTRAL, SUPRISED, ANGRY, EMBARRASSED}


enum BlendMode {NONE, MULTIPLY, DARKEN, OVERLAY, SCREEN, COLOR_BURN}


#Inventory
enum ItemResource {WOOD, METAL, CLOTH, BOOTY}
enum ItemType {PLAYER, SHOP, CART}
enum ItemFood {PUFFER, TUNA, CRAB}

#World
enum PortType {FISHING, RESOURCE, CREW}
