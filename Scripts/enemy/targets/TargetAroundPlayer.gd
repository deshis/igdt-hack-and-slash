extends TargetProvider
class_name TargetAroundPlayer

@export var radius := 100.0

func get_target(_enemy: Node2D, player: Node2D) -> Vector2:
	var random_offset = Vector2(randf_range(-radius, radius), randf_range(-radius, radius))
	return player.global_position + random_offset
