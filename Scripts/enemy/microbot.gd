extends EnemyController
class_name Microbot

var target_dist_min := 100.0
var target_dist_max := 250.0

func _ready() -> void:
	attack_area_hitbox.disabled = true
	nav_agent.target_desired_distance = randf_range(target_dist_min, target_dist_max)

func _on_wait_after_attack_timer_timeout() -> void:
	nav_agent.target_desired_distance = randf_range(target_dist_min, target_dist_max)
	target_provider = TargetPlayer.new()
