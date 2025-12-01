extends Mage
class_name AugMage

@export var aoe_attack_small: PackedScene = null
@export var small_aoe_max := 10
@export var small_aoe_min := 3
@export var aoe_radius_max := 1.5
@export var aoe_radius_min := 0.7

func process_tp_attack() -> void:
	if state_timer > 0:
		return
	
	change_state(COOLDOWN, cooldown_duration)
	
	perform_attack(aoe_attack)
	
	var small_aoe_amount = randi_range(small_aoe_min, small_aoe_max)
	for i in range(small_aoe_amount):
		var wait_time = randf_range(0.05, 0.13)
		await get_tree().create_timer(wait_time).timeout
		
		var angle = randf_range(0, TAU)
		var dir = Vector2(cos(angle), sin(angle))
		var dist = randf_range(aoe_radius_min, aoe_radius_max)
		var offset = dir * dist
		
		if state != STUN:
			perform_attack(aoe_attack_small, offset)
		else:
			return
