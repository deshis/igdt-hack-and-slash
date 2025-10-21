extends CharacterBody2D

@export var speed := 250.0
@export var health := 100.0
@export var acceleration := 20.0

@export var player: Node2D
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D

var rotation_speed := 8.0

func _physics_process(delta: float) -> void:
	var next_pos = nav_agent.get_next_path_position()
	var dir = (next_pos - global_transform.origin).normalized()
	
	apply_movement(delta, dir)
	update_facing_dir(delta, dir)
	
	move_and_slide()

func update_facing_dir(delta: float, dir: Vector2) -> void:
	var target_angle = dir.angle() + Vector2.DOWN.angle()
	rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)

func apply_movement(delta: float, dir: Vector2) -> void:
	velocity = lerp(velocity, dir * speed, acceleration * delta)

func find_path() -> void:
	nav_agent.target_position = player.global_position

func _on_timer_timeout() -> void:
	find_path()
