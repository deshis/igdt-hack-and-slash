extends Node2D

@export var damage := 2.0
@export var hitbox_duration := 0.05
@export var animation_duration := 2.0

@onready var area: Area2D = $Area2D

signal attack_hit(target: Node, damage: float)

func _ready() -> void:
	start_attack()

func start_attack() -> void:
	for body in area.get_overlapping_areas():
		_on_area_2d_area_entered(body)
	
	# hitbox duration
	await get_tree().create_timer(hitbox_duration).timeout
	area.monitoring = false
	
	# animation duration
	await get_tree().create_timer(animation_duration - hitbox_duration).timeout
	queue_free()

func _on_area_2d_area_entered(_area: Area2D) -> void:
	print("area 2d entered")
	attack_hit.emit(area, damage)
