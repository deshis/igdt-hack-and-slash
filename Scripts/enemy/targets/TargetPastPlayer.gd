extends TargetProvider
class_name TargetPastPlayer

@export var length := 200

func get_target(enemy: Node2D, player: Node2D) -> Vector2:
	var dir = (player.global_position - enemy.global_position).normalized()
	return player.global_position + dir * length
