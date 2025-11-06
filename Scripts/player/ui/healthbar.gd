extends Control

@onready var progress_bar: ProgressBar = $MarginContainer/ProgressBar
var player: Player


func _on_player_ready() -> void:
	progress_bar.max_value = player.max_health
	progress_bar.value = player.health
	player.update_health_bar.connect(update_health)

func setup(p: Player) -> void:
	player = p
	_on_player_ready()

func update_health(health:float)->void:
	progress_bar.value = health
