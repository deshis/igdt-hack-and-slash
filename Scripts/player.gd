class_name Player extends CharacterBody2D

var input: Vector2

@export var movement_speed := 500.0
@export var acceleration := 15.0

@export var max_HP := 100.0
@export var HP := 100.0

signal update_hp_bar
signal dash_used

var can_dash:= true
var dashing = false
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer
@onready var dash_length_timer: Timer = $DashLengthTimer
var dash_cooldown:= 3.0
var dash_length:= 0.15
var dash_speed:= 2500

var current_speed:= movement_speed


func _physics_process(delta) -> void:
	update_input()
	
	if Input.is_action_pressed("movement_ability") and can_dash and input.length() > 0:
		can_dash = false
		dashing = true
		dash_length_timer.start(dash_length)
		dash_cooldown_timer.start(dash_cooldown)
		current_speed = dash_speed
		dash_used.emit(dash_cooldown)
	else:
		velocity = lerp(velocity, input * current_speed, acceleration * delta)
	
	move_and_slide()


func update_input() -> void:
	if not dashing:
		input.x = Input.get_axis("move_left", "move_right")
		input.y = Input.get_axis("move_up", "move_down")
	input = input.normalized()


func _on_dash_cooldown_timer_timeout() -> void:
	can_dash=true


func _on_dash_length_timer_timeout() -> void:
	current_speed = movement_speed
	dashing = false


func take_damage(dmg:float) -> void:
	HP -= dmg
	update_hp_bar.emit(HP)
	if HP <= 0.0:
		die()


func die() -> void:
	queue_free()
