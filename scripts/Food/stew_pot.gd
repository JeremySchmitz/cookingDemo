extends Dishwear
class_name StewPot

@export var waterDamage: Array[int] = []

@onready var hitbox: Hitbox = $Hitbox
@onready var anim: AnimationPlayer = %StewAnimPlayer
@onready var nutrition: Nutrition = $Nutrition

var nutritionSap = 0.9
var previousNutrition = -1

func _on_health_water_temp_updated(val: int) -> void:
	if waterDamage[val] != null:
		hitbox.damage = waterDamage[val]
		match val:
			0:
				anim.play('RESET')
			1:
				anim.play('RESET')
			2:
				anim.play('Stew_Simmer_low')
			3:
				anim.play('Stew_Simmer_hi')
			4:
				anim.play('Stew_Boil_low')
			5:
				anim.play('Stew_Boil_hi')

func _on_area_2d_area_entered(area: Area2D) -> void:
	if moving: return

	var parent = area.get_parent()
	if (parent is Food &&
		parent.get_parent() != self &&
		parent.get_parent().name != 'Organs' &&
		parent.get_parent().name != 'VisibleOrgans' &&
		parent.get_parent().name != 'TopOrgans' &&
		parent.get_parent().name != 'BarrelFoodNode'
		):
		call_deferred("_reparent", parent, self)

	var nut: Nutrition = parent.find_child('Nutrition')
	if !nut || nut.nutrtionUpdated.is_connected(_onNutritionUpdated): return
	nut.nutrtionUpdated.connect(_onNutritionUpdated)


func _on_area_2d_area_exited(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent is Food and parent.get_parent() == self:
		call_deferred("_reparent", parent, get_node("/root/Kitchen"))
		
	var nut: Nutrition = parent.find_child('Nutrition')
	if !nut || !nut.nutrtionUpdated.is_connected(_onNutritionUpdated): return
	nut.nutrtionUpdated.disconnect(_onNutritionUpdated)


func _onNutritionUpdated(nut: Nutrition) -> void:
	var change
	if previousNutrition == -1:
		change = nut.nutrition * nutritionSap
		nutrition.nutrition = change
		
	else:
		change = abs(nut.nutrition - previousNutrition) * nutritionSap
		nutrition.nutrition += change

	nut.nutrition = max(0, nut.nutrition - change)
	nut.maxNutrition = max(0, nut.maxNutrition - change)
	previousNutrition = nut.nutrition

	%LabelNutrition.text = str(nutrition.nutrition)
