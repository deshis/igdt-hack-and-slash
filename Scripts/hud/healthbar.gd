extends Control

@onready var progress_bar: ProgressBar = $MarginContainer/ProgressBar
var character: Node
var is_static := true

func setup(c: Node, value: float, max_value: float) -> void:
	character = c
	progress_bar.max_value = max_value
	progress_bar.value = value
	character.update_health_bar.connect(update_health)

func update_health(health:float)->void:
	progress_bar.value = health


func _physics_process(_delta: float) -> void:
	if character and not is_static:
		var world_pos = character.global_position + Vector2(0, -80)
		var screen_pos = get_viewport().get_canvas_transform() * world_pos
		global_position = screen_pos - size / 2
