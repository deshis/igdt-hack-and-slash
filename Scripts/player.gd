class_name Player extends CharacterBody2D

var input: Vector2

@export var movement_speed := 500.0
@export var acceleration := 15.0

@export var max_HP := 100.0
@export var HP := 100.0

signal update_hp_bar
signal dash_used
signal light_attack_used


var can_attack := true
var attacking := false
@onready var light_attack_cooldown_timer: Timer = $LightAttackCooldownTimer
@onready var light_attack_length_timer: Timer = $LightAttackLengthTimer
@onready var light_attack_sprite = $light_attack
var light_attack_cooldown:= 0.2
var light_attack_length:= 0.1

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
	update_facing_dir()
	
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
	
	if Input.is_action_pressed("light_attack") and can_attack:
		can_attack = false
		light_attack_length_timer.start(light_attack_length)
		light_attack_cooldown_timer.start(light_attack_cooldown)
		light_attack_used.emit(light_attack_cooldown)
		light_attack()


func update_input() -> void:
	if not dashing:
		input.x = Input.get_axis("move_left", "move_right")
		input.y = Input.get_axis("move_up", "move_down")
	input = input.normalized()

func update_facing_dir() -> void:
	var screen_center: Vector2 = get_viewport_rect().size / 2
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	
	var dir: Vector2 = mouse_pos - screen_center
	rotation = dir.angle() + PI / 2


func light_attack() -> void:
	light_attack_sprite.visible = true
	attacking = true


func _on_light_attack_length_timer_timeout() -> void:
	light_attack_sprite.visible = false
	attacking = false


func _on_light_attack_cooldown_timer_timeout() -> void:
	can_attack = true


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
