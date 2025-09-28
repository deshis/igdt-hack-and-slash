extends Control

@export var player: Player

@onready var dash_cooldown_progress_bar: ProgressBar = $MarginContainer/HBoxContainer/DashCooldown/ProgressBar
@onready var dash_cooldown_timer: Timer = $MarginContainer/HBoxContainer/DashCooldown/Timer


func _ready() -> void:
	player.dash_used.connect(update_dash_cooldown)


func _process(_delta: float) -> void:
	dash_cooldown_progress_bar.value = dash_cooldown_timer.time_left


func update_dash_cooldown(cooldown:float)->void:
	dash_cooldown_progress_bar.max_value = cooldown
	dash_cooldown_progress_bar.value = cooldown
	dash_cooldown_timer.start(cooldown)
	
