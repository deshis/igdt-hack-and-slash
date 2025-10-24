extends Control

@export var player: Player

@onready var progress_bar: ProgressBar = $MarginContainer/ProgressBar


func _ready() -> void:
	progress_bar.max_value = player.max_HP
	progress_bar.value = player.HP
	player.update_hp_bar.connect(update_health)


func update_health(HP:float)->void:
	progress_bar.value = HP
