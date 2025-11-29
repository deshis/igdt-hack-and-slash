extends TargetProvider
class_name TargetPastPlayer

@export var length := 200

func get_target(enemy: Node2D) -> Vector2:
	var dir = (GameManager.player.global_position - enemy.global_position).normalized()
	return GameManager.player.global_position + dir * length
