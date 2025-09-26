extends ProgressBar

@export var player: Player

func _ready() -> void:
	max_value = player.max_HP
	value = player.HP
	player.update_hp_bar.connect(update_health)

func update_health()->void:
	value = player.HP
