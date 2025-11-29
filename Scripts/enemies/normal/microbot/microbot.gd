extends EnemyController
class_name Microbot

var target_dist_min := 100.0
var target_dist_max := 250.0

func change_state(new_state: String, duration := 0.0):
	super.change_state(new_state, duration)
	
	match state:
		IDLE:
			nav_agent.target_desired_distance = randf_range(target_dist_min, target_dist_max)
