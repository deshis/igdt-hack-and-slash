extends Node

func _ready() -> void:
	GameManager.start_game()
	queue_free()
