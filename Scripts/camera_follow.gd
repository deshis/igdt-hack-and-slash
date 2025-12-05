extends Node3D

@onready var player: Player = GameManager.player

func _process(_delta: float) -> void:
	if player:
		global_position = Vector3(player.global_position.x, global_position.y, player.global_position.z)
