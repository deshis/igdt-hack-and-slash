extends TargetProvider
class_name TargetPlayer

func get_target(_enemy: Node2D, player: Node2D) -> Vector2:
	return player.global_position
