extends TargetProvider
class_name TargetAwayFromPlayer

func get_target(enemy: Node2D) -> Vector2:
	var dir = (enemy.global_position - GameManager.player.global_position).normalized()
	return enemy.global_position + dir * 256
