extends Control

@export var player: Player

@onready var progress_bar: ProgressBar = $MarginContainer/ProgressBar


func _ready() -> void:
	progress_bar.max_value = player.max_health
	progress_bar.value = player.health
	player.update_health_bar.connect(update_health)


func update_health(health:float)->void:
	progress_bar.value = health
