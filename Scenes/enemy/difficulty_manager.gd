extends Node2D
class_name DifficultyManager

@export var starting_level := 0
@export var seconds_per_level := 20
@export var enemy_spawn_amount_per_level := 0.2
@export var credits_per_level := 0.5

var difficulty_level := 1
var difficulty := 0.0

func _ready() -> void:
	difficulty = starting_level

func _physics_process(delta: float) -> void:
	difficulty += delta / seconds_per_level

	if difficulty > difficulty_level:
		difficulty_level += 1
