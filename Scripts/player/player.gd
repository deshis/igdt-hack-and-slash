class_name Player extends CharacterBody2D

var input: Vector2
var can_look_around := true
var can_move := true

@export var movement_speed := 500.0
@export var acceleration := 15.0
var current_speed:= movement_speed

@export var max_health := 10.0
@export var health := 10.0

var percent_damage_reduction := 0
var flat_damage_reduction := 0
var life_steal := 0.0
var life_stolen := 0.0

@onready var invulnerability_length_timer: Timer = $Timers/InvulnerabilityLengthTimer
var damageable := true

## Base stats
#might be useful in the future
#var base_attack_light_damage := 1 # old 2
#var base_attack_heavy_damage := 2 # old 4
#
#var base_light_attack_cooldown:= 0.3 # old 0.2
#var base_heavy_attack_cooldown:= 0.5 # old 0.4
#

@export var attack_light_damage := 1
@export var attack_heavy_damage := 2

signal update_health_bar
signal dash_used
signal primary_attack_used
signal secondary_attack_used
signal item_picked_up(area)

var can_attack := true
var attacking := false
@onready var health_regen_timer: Timer = $Timers/HealthRegenTimer
@onready var attack_cooldown_timer: Timer = $Timers/AttackCooldownTimer
@onready var attack_length_timer: Timer = $Timers/AttackLengthTimer

@onready var light_attack = $AttackLight
@onready var light_attack_hitbox = $AttackLight/CollisionShape2D
@onready var light_attack_sprite: Sprite2D = $AttackLight/CollisionShape2D/Sprite2D
var light_attack_shape: RectangleShape2D
var light_attack_visual_shape: Sprite2D

var light_attack_cooldown:= 0.3
#duration the hitbox lingers
var light_attack_length:= light_attack_cooldown/2

@onready var heavy_attack = $AttackHeavy
@onready var heavy_attack_hitbox = $AttackHeavy/CollisionShape2D
@onready var heavy_attack_sprite: Sprite2D = $AttackLight/CollisionShape2D/Sprite2D
var heavy_attack_shape: RectangleShape2D
var heavy_attack_visual_shape: Sprite2D

var performing_heavy_attack := false
var heavy_attack_dash_decay := 0.6
var heavy_attack_dash_speed := movement_speed * 6.0

var heavy_attack_cooldown:= 0.5
#duration the hitbox lingers
var heavy_attack_length:= heavy_attack_cooldown/2

var can_dash:= true
var dashing = false
@onready var dash_cooldown_timer: Timer = $Timers/DashCooldownTimer
@onready var dash_length_timer: Timer = $Timers/DashLengthTimer
var dash_cooldown:= 3.0
var dash_length:= 0.15
var dash_speed:= 2500

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

var health_regen:= 0

func _ready() -> void:
	light_attack_hitbox.disabled = true
	light_attack.visible = false
	heavy_attack_hitbox.disabled = true
	heavy_attack.visible = false
	
	light_attack_shape = light_attack_hitbox.shape
	heavy_attack_shape = heavy_attack_hitbox.shape
	
# Function for regenerating health, defaults at zero, gets incremented from items


func _physics_process(delta) -> void:
	update_input()
	if can_look_around:
		update_facing_dir()
	
	if Input.is_action_pressed("movement_ability") and input.length() > 0 and can_dash:
		perform_dash()
	elif performing_heavy_attack:
		current_speed *= heavy_attack_dash_decay
		apply_movement(delta, Vector2.UP.rotated((rotation)))
	elif can_move:
		apply_movement(delta, input)
	
	if Input.is_action_pressed("light_attack") and can_attack:
		perform_light_attack()
	
	if Input.is_action_just_pressed("heavy_attack") and can_attack:
		perform_heavy_attack()
	
	move_and_slide()


func apply_movement(delta: float, dir: Vector2) -> void:
	velocity = lerp(velocity, dir * current_speed, acceleration * delta)


func update_input() -> void:
	if not dashing:
		input.x = Input.get_axis("move_left", "move_right")
		input.y = Input.get_axis("move_up", "move_down")
	input = input.normalized()
	
	if input.x == 0 and input.y == 0:
		anim_sprite.play("idle")
	else:
		anim_sprite.play("f-walk")
		

func update_facing_dir() -> void:
	var screen_center: Vector2 = get_viewport_rect().size / 2
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	
	var dir: Vector2 = mouse_pos - screen_center
	rotation = dir.angle()+ Vector2.DOWN.angle()


func perform_light_attack() -> void:
	
	# enable hitbox and visuals
	light_attack.visible = true
	light_attack_hitbox.disabled = false
	
	attacking = true
	can_attack = false
	
	SoundManager.play_sfx("light_attack", global_position)
	
	attack_length_timer.start(light_attack_length)
	attack_cooldown_timer.start(light_attack_cooldown)
	primary_attack_used.emit(light_attack_cooldown)


func perform_heavy_attack() -> void:

	# enable hitbox and visuals
	heavy_attack.visible = true
	heavy_attack_hitbox.disabled = false
	
	attacking = true
	can_attack = false
	can_look_around = false
	performing_heavy_attack = true
	
	SoundManager.play_sfx("heavy_attack", global_position)
	
	attack_length_timer.start(heavy_attack_length)
	attack_cooldown_timer.start(heavy_attack_cooldown)
	secondary_attack_used.emit(heavy_attack_cooldown)
	
	current_speed = heavy_attack_dash_speed

func perform_dash():
	can_dash = false
	dashing = true
	
	SoundManager.play_sfx("dash", global_position)
	
	dash_length_timer.start(dash_length)
	dash_cooldown_timer.start(dash_cooldown)
	current_speed = dash_speed
	dash_used.emit(dash_cooldown)

func deal_damage(area: Area2D, amount: float) -> void:
	var enemy = area.get_parent() as EnemyController
	
	#Lifesteal
	#NOTE: Might just want to make this flat
	life_stolen = amount * (life_steal/100)
	snappedf(life_stolen,3)
	health += life_stolen
	
	if health > max_health:
		health = max_health
		
	print(amount)
	update_health_bar.emit(health)
	
	enemy.take_damage(amount)

func take_damage(damage:float) -> void:
	if invulnerability_length_timer.time_left > 0:
		return
	
	invulnerability_length_timer.start()
	
	#Damage reduction
	#NOTE: Applying flat damage reduction before percent damage reduction results in less mitigation
	damage -= flat_damage_reduction
	damage *= (100.0 - percent_damage_reduction)/100
	snappedf(damage,3)
	health -= damage
	print(damage)
	update_health_bar.emit(health)
	
	if health <= 0.0:
		die()

func die() -> void:
	queue_free()


func _on_attack_length_timer_timeout() -> void:
	# TODO: need to make this smarter later, but for now it just disables both attacks
	light_attack_hitbox.disabled = true
	light_attack.visible = false
	heavy_attack_hitbox.disabled = true
	heavy_attack.visible = false
	
	attacking = false
	performing_heavy_attack = false
	current_speed = movement_speed

func _on_attack_cooldown_timer_timeout() -> void:
	can_attack = true
	can_move = true
	can_look_around = true

func _on_dash_cooldown_timer_timeout() -> void:
	can_dash=true

func _on_dash_length_timer_timeout() -> void:
	current_speed = movement_speed
	dashing = false

func _on_attack_light_area_entered(area: Area2D) -> void:
	deal_damage(area, attack_light_damage)

func _on_attack_heavy_area_entered(area: Area2D) -> void:
	deal_damage(area, attack_heavy_damage)

func _on_item_pickup_detector_area_entered(area: Area2D) -> void:
	item_picked_up.emit(area)


func _on_invulnerability_length_timer_timeout() -> void:
	damageable = true
	
	
func _on_health_regen_timer_timeout() -> void:
	if health >= max_health:
		return
		
	health += health_regen
	update_health_bar.emit(health)
	
	if health > max_health:
		health = max_health
