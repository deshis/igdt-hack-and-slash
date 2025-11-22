extends Node2D
class_name DifficultyManager

@export var starting_level := 0
@export var seconds_per_level := 20
@export var enemy_spawn_amount_per_level := 0.2
@export var credits_per_level := 0.5
@export var health_per_level := 0.1
@export var damage_per_level := 0.05

var difficulty_level := 1
var difficulty := 0.0

var enemy_spawn_amount_mult := 1.0
var credits_mult := 1.0
var health_mult := 1.0
var damage_mult := 1.0

func _ready() -> void:
	difficulty = starting_level

func _physics_process(delta: float) -> void:
	difficulty += delta / seconds_per_level

	if difficulty > difficulty_level:
		difficulty_level += 1
		update_multipliers()

func update_multipliers() -> void:
	health_mult += health_per_level
	damage_mult += damage_per_level
	enemy_spawn_amount_mult += enemy_spawn_amount_per_level
	credits_mult += credits_per_level
