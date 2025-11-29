extends TargetProvider
class_name TargetSelf

func get_target(enemy: Node2D) -> Vector2:
	return enemy.global_position
