class_name Character extends CharacterBody2D

var movement_speed: float
var acceleration: float

var HP: float
var max_HP: float


func take_damage(dmg:float) -> void:
	HP -= dmg
	if HP <= 0.0:
		die()

func die() -> void:
	queue_free()
