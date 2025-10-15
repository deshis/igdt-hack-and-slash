class_name Player extends CharacterBody2D


@export var inventory: Control
@export var cameraRef: Camera2D

var input: Vector2

var can_move := true
var can_look_around := true
@export var movement_speed := 500.0
@export var acceleration := 15.0

@export var max_HP := 100.0 : set= _set_hp
@export var HP := 100.0


func _set_hp(val:int):
	max_HP=val
	if HP> val:
		HP=val


@export var Attack := 1 

@export var Movement := 1 : set= _set_mov

func _set_mov(val:int):
	Movement = val
	movement_speed=val*500
	acceleration=val*15

signal update_hp_bar
signal dash_used
signal attack_used


var can_attack := true
var attacking := false
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer
@onready var attack_length_timer: Timer = $AttackLengthTimer

@onready var light_attack_object = $LightAttackObject
var light_attack_cooldown:= 0.2
var light_attack_length:= 0.1

@onready var heavy_attack_object = $HeavyAttackObject
var heavy_attack_cooldown:= 0.4
var heavy_attack_length:= 0.3

@export var Attack_Speed := 1 : set= _set_as
func _set_as(val:int):
	Attack_Speed=val
	light_attack_cooldown=0.2/Attack_Speed
	heavy_attack_cooldown=0.4/Attack_Speed




var can_dash:= true
var dashing = false
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer
@onready var dash_length_timer: Timer = $DashLengthTimer
var dash_cooldown:= 3.0
var dash_length:= 0.15
var dash_speed:= 2500

func incrementItem(item:Item):
	Attack += item.Attack
	Attack_Speed += item.Attack_speed
	max_HP += item.Health
	Movement += item.Movement_speed
	
func loseItem(item:Item):
	Attack -= item.Attack
	Attack_Speed -= item.Attack_speed
	max_HP -= item.Health
	Movement -= item.Movement_speed

var current_speed:= movement_speed

	


func _physics_process(delta) -> void:
	update_input()
	if can_look_around:
		update_facing_dir()
	
	if Input.is_action_pressed("movement_ability") and can_move and can_dash and input.length() > 0:
		dash()
	elif can_move:
		apply_movement(delta, input)
	
	if Input.is_action_pressed("light_attack") and can_attack:
		light_attack()
	
	if Input.is_action_just_pressed("heavy_attack") and can_attack:
		heavy_attack(delta)
	
	move_and_slide()


func apply_movement(delta: float, dir: Vector2) -> void:
	## delta seems to limit dash speed here? I think move and slide already does something to account for delta.
	# velocity = lerp(velocity, dir * current_speed, acceleration * delta)
	velocity = lerp(velocity, dir * current_speed, 1)


func update_input() -> void:
	if not dashing:
		input.x = Input.get_axis("move_left", "move_right")
		input.y = Input.get_axis("move_up", "move_down")
	input = input.normalized()


func update_facing_dir() -> void:
	var screen_center: Vector2 = get_viewport_rect().size / 2
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	
	var dir: Vector2 = mouse_pos - screen_center
	rotation = dir.angle()+ Vector2.DOWN.angle()


func light_attack() -> void:
	can_attack = false
	light_attack_object.visible = true
	attack_length_timer.start(light_attack_length)
	attack_cooldown_timer.start(light_attack_cooldown)
	attack_used.emit(light_attack_cooldown)
	attacking = true


func heavy_attack(delta: float) -> void:
	can_attack = false
	can_move = false
	can_look_around = false
	
	heavy_attack_object.visible = true
	attack_length_timer.start(heavy_attack_length)
	attack_cooldown_timer.start(heavy_attack_cooldown)
	attack_used.emit(heavy_attack_cooldown)
	attacking = true
	
	# TODO: could make it smoother
	velocity = Vector2(0,0)
	apply_movement(delta, Vector2.UP.rotated(rotation)/(heavy_attack_length+heavy_attack_cooldown))


func dash():
	can_dash = false
	dashing = true
	dash_length_timer.start(dash_length)
	dash_cooldown_timer.start(dash_cooldown)
	current_speed = dash_speed
	dash_used.emit(dash_cooldown)


func _on_attack_length_timer_timeout() -> void:
	# TODO: need to make this smarter later, but for now it just disables both attacks
	light_attack_object.visible = false
	heavy_attack_object.visible = false
	attacking = false


func _on_attack_cooldown_timer_timeout() -> void:
	can_attack = true
	can_move = true
	can_look_around = true


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
