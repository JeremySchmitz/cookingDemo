extends Node2D
class_name Kitchen


const BOWL_SCENE = preload("res://Scenes/food/bowl.tscn")
const RESULTS_SCENE = preload("res://Scenes/food/results.tscn")
const FOODBARREL_SCENE = preload("res://Scenes/food/food_barrel.tscn")

@export var cameraMoveWait = .2;
@onready var boneParticles: CPUParticles2D = $BoneParticles

@onready var crew := CrewStatus.crew
@onready var staminaBar: CustomProgressBar = %StaminaBar
@onready var healthBar: CustomProgressBar = %HealthBar
@export var inventory: Inventory = CrewStatus.inventory

@export var staminaPeriod := 0.3
@export var staminaRestPeriod := 2
@export var recoverSpeed := 10
var sTimer: Timer
var recovering = false


func _ready() -> void:
	for food in inventory.food:
		var foodScene: PackedScene = load(food.scenePath) as PackedScene
		var barrel: FoodBarrel = FOODBARREL_SCENE.instantiate()
		%FoodBarrelWrapper.add_child(barrel)
		barrel.initialize(foodScene, food.name, food.count)

	for i in range(0, crew.size()):
		_buildBowl(i)

	_initializeTimer()
	SignalBus.dragging.connect(_exhaust)
	SignalBus.drop.connect(_recover)
	SignalBus.progressBarFull.connect(_on_progress_bar_full)
	SignalBus.progressBarEmpty.connect(_on_progress_bar_empty)

	
func _buildBowl(i: int):
	var scene: Bowl = BOWL_SCENE.instantiate()
	scene.setNameTag(crew[i].name, crew[i].role)
	$Bowls.add_child(scene)
	scene.scale *= 2
	scene.position = Vector2(
		get_viewport_rect().size.x + 200 + (300 * i),
		 200)
	
func _on_dinner_bell_btn_pressed() -> void:
	var crewBefore = CrewStatus.crew
	var bowls = $Bowls.get_children()

	for bowl: Bowl in bowls:
		var i = crew.find_custom(func(x): return x.name == bowl.getName())
		var member = crew[i]
		if member:
			(member as Crew).eat(bowl.nutrition, bowl.poison)
		else: printerr("Could Not Find Crew Member: %s", name)
		
	var resultsAttrs: Array[GlobalEnums.CrewAttrs] = [
		GlobalEnums.CrewAttrs.HEALTH,
		GlobalEnums.CrewAttrs.HUNGER
		]
	SceneLoader.gotoResults(crewBefore, crew, resultsAttrs)
	
func buildResultsScn(crewBefore: Array[Crew], crewAfter: Array[Crew]):
	var results = RESULTS_SCENE.instantiate()
	results.crewBefore = crewBefore
	results.crewAfter = crew
	var resultsAttrs: Array[GlobalEnums.CrewAttrs] = [GlobalEnums.CrewAttrs.HEALTH, GlobalEnums.CrewAttrs.HUNGER]
	results.buildResults(resultsAttrs)
	results.nextScene = "encounter"

	return results


func _on_knife_chopper_cut_bone(pos: Vector2) -> void:
	_emitBoneParticles(pos)

func _on_knife_slicer_cut_bone(pos: Vector2) -> void:
	_emitBoneParticles(pos)
	
func _emitBoneParticles(pos: Vector2):
	boneParticles.global_position = pos
	boneParticles.emitting = true


func _initializeTimer():
	sTimer = Timer.new()
	add_child(sTimer)

func _setStamina(weight: float, subtract = true):
	if subtract: weight *= -5
	%StaminaBar.value += weight

func _startTimer(weight: float, subtract = true):
	staminaBar.visible = true
	if !sTimer.is_stopped(): return
	if sTimer.timeout.is_connected(_setStamina):
		sTimer.timeout.disconnect(_setStamina)

	sTimer.connect("timeout", _setStamina.bind(weight, subtract))
	sTimer.wait_time = staminaPeriod
	sTimer.start()

func _exhaust(weight: float):
	if recovering:
		sTimer.stop()
		recovering = false
	_startTimer(weight)

func _recover():
	if !recovering:
		sTimer.stop()
		recovering = true
	_rest()

func _on_progress_bar_full(type: GlobalEnums.ProgressTypes):
	if type == GlobalEnums.ProgressTypes.STAMINA:
		sTimer.stop()
		staminaBar.visible = false
		return

func _on_progress_bar_empty(type: GlobalEnums.ProgressTypes):
	if type == GlobalEnums.ProgressTypes.STAMINA:
		SignalBus.stopDrag.emit()
		return

func _rest():
	var timer = Timer.new()
	timer.wait_time = staminaRestPeriod
	timer.connect("timeout", (
		func():
			timer.queue_free()
			_startTimer(recoverSpeed, false)
			)
	)

	add_child(timer)
	timer.start()

func _on_health_bar_value_change(v: float) -> void:
	staminaBar.maxVal = v
