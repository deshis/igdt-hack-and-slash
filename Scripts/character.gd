class_name Character extends CharacterBody2D

var movement_speed: int
var acceleration: int

var HP: int
var max_HP: int


func take_damage(dmg:int) -> void:
	HP -= dmg
	if HP <= 0:
		die()

func die() -> void:
	queue_free()
