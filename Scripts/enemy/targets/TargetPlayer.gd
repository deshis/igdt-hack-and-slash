extends TargetProvider
class_name TargetPlayer

func get_target(_enemy: Node2D) -> Vector2:
	return GameManager.player.global_position
