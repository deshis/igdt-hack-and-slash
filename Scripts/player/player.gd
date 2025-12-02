class_name Player extends CharacterBody2D

signal update_health_bar

signal dash_used

signal primary_attack_used
signal secondary_attack_used
signal active_item_used

signal item_picked_up(area)

signal game_over

# PLAYER STUFF IDK WHAT TO CALL THESE SOMEONE RENAME OR REORGANIZE THIS
@onready var sprite = $PlayerSprite

@onready var health_regen_timer: Timer = $Timers/HealthRegenTimer
@onready var invulnerability_length_timer: Timer = $Timers/InvulnerabilityLengthTimer
var player_on_damage_particles_scene = preload("res://Scenes/particles/player_on_hit_particles_3D.tscn")
@onready var model = $SubViewport/model

var hit_flash_timer := 0.0
var hit_flash_duration := 0.3

var overlapping_pickups := []

# PLAYER STATS
@export var max_health := 10.0
@export var health := 10.0
var health_regen:= 0

var percent_damage_reduction := 0
var flat_damage_reduction := 0

var life_steal := 0.0
var life_stolen := 0.0

# MOVEMENT
@export var movement_speed := 500.0
@export var acceleration := 15.0
var default_speed = movement_speed
var current_speed := movement_speed
var input: Vector2

# DASH
@onready var dash_cooldown_timer: Timer = $Timers/DashCooldownTimer
@onready var dash_length_timer: Timer = $Timers/DashLengthTimer

var dash_speed:= 2500
var dash_duration:= 0.15
var dash_cooldown:= 3.0
var can_dash := true

# ATTACKS
@export var attack_light_damage := 1.0
@export var attack_heavy_damage := 2.0

@onready var light_attack = $AttackLight
@onready var heavy_attack = $AttackHeavy

@onready var light_attack_hitbox = $AttackLight/CollisionShape2D
@onready var heavy_attack_hitbox = $AttackHeavy/CollisionShape2D

@onready var light_attack_sprite: Sprite2D = $AttackLight/CollisionShape2D/Sprite2D
@onready var heavy_attack_sprite: Sprite2D = $AttackLight/CollisionShape2D/Sprite2D

var light_attack_speed_scale := 1.0

var light_attack_shape: RectangleShape2D
var heavy_attack_shape: RectangleShape2D

var light_attack_visual_shape: Sprite2D
var heavy_attack_visual_shape: Sprite2D

var heavy_attack_dash_speed := movement_speed * 6.0
var heavy_attack_dash_decay := 0.6

var heavy_attack_cooldown:= 0.5 # this is used in item stats but it feels redundant now?
var heavy_attack_windup_duration := 0.333

var primary_attack_active_dot: DotResource = null
var secondary_attack_active_dot: DotResource = null

var primary_attack_active_debuff: DebuffResource = null
var secondary_attack_active_debuff: DebuffResource = null

# ACTIVE ABILITY
@onready var active_item_cooldown_timer: Timer = $Timers/ItemActiveCooldownTimer
var active_item_cooldown := 5.0
var can_active_item := true

# STATE MACHINE
var state = IDLE
var state_timer := 0.0

const IDLE = "idle"
const MOVE = "move"
const DASH = "dash"
const LIGHT_ATTACK = "light_attack"
const HEAVY_ATTACK_WINDUP = "heavy_attack_windup"
const HEAVY_ATTACK = "heavy_attack"

func _ready() -> void:
	print("Q to use active item")
	
	light_attack_hitbox.disabled = true
	light_attack.visible = false
	heavy_attack_hitbox.disabled = true
	heavy_attack.visible = false
	
	light_attack_shape = light_attack_hitbox.shape
	heavy_attack_shape = heavy_attack_hitbox.shape
	
	change_state(IDLE)
# Function for regenerating health, defaults at zero, gets incremented from items

func _physics_process(delta: float) -> void:
	state_timer -= delta
	
	if state != DASH: update_input()
	update_state()
	process_state(delta)
	
	if Input.is_action_pressed("interact"):
		var item = get_closest_pickup()
		if item:
			item_picked_up.emit(item)
	
	if Input.is_action_just_pressed("active_item") and can_active_item:
		use_active_item()
	
	if hit_flash_timer > 0:
		hit_flash_timer = 0 # TODO: temporary fix to avoid infinite loop
		hit_flash()
	
	move_and_slide()

func update_state() -> void:
	match state:
		IDLE, MOVE:
			if Input.is_action_just_pressed("movement_ability") and input.length() > 0 and can_dash:
				change_state(DASH)
			
			if Input.is_action_pressed("light_attack"):
				change_state(LIGHT_ATTACK)
			
			if Input.is_action_just_pressed("heavy_attack"):
				change_state(HEAVY_ATTACK_WINDUP)
		
		DASH:
			if Input.is_action_pressed("light_attack"):
				change_state(LIGHT_ATTACK)
			
			if Input.is_action_just_pressed("heavy_attack"):
				change_state(HEAVY_ATTACK)
		
		LIGHT_ATTACK, HEAVY_ATTACK_WINDUP, HEAVY_ATTACK:
			if Input.is_action_just_pressed("movement_ability") and input.length() > 0 and can_dash:
				change_state(DASH)

func change_state(new_state) -> void:
	exit_state(state)
	enter_state(new_state)

func enter_state(new_state) -> void:
	state = new_state
	
	match state:
		IDLE, MOVE:
			current_speed = movement_speed
		
		DASH:
			state_timer = dash_duration
			print(dash_duration)
			perform_dash()
		
		LIGHT_ATTACK:
			perform_light_attack()
		
		HEAVY_ATTACK_WINDUP:
			current_speed = heavy_attack_dash_speed
			state_timer = heavy_attack_windup_duration
			set_facing_dir()
			sprite.heavy_attack(rotation)
		
		HEAVY_ATTACK:
			perform_heavy_attack()

func exit_state(st: String) -> void:
	match st:
		LIGHT_ATTACK:
			stop_light_attack()
		
		HEAVY_ATTACK:
			stop_heavy_attack()
		
		DASH:
			stop_dash()

func process_state(delta: float) -> void:
	match state:
		IDLE, MOVE:
			process_move(delta)
		
		DASH:
			process_dash(delta)
		
		HEAVY_ATTACK_WINDUP:
			process_heavy_attack_windup(delta)
		
		HEAVY_ATTACK:
			process_heavy_attack(delta)


func perform_dash():
	can_dash = false
	current_speed = dash_speed
	dash_cooldown_timer.start(dash_cooldown)
	dash_used.emit(dash_cooldown)
	
	sprite.start_dash()
	
	SoundManager.play_sfx("dash", global_position)

func perform_light_attack() -> void:
	velocity = Vector2.ZERO
	set_facing_dir()
	
	light_attack.visible = true
	light_attack_hitbox.disabled = false
	
	# this is for the hud icon but idk if we should have those for light/heavy attacks
	# light_attack_used.emit(light_attack_cooldown)
	
	sprite.light_attack(rotation)
	
	SoundManager.play_sfx("light_attack", global_position)

func perform_heavy_attack() -> void:
	heavy_attack.visible = true
	heavy_attack_hitbox.disabled = false
	
	# this is for the hud icon but idk if we should have those for light/heavy attacks
	#heavy_attack_used.emit(heavy_attack_cooldown)
	
	SoundManager.play_sfx("heavy_attack", global_position)

func use_active_item():
	can_active_item = false
	active_item_cooldown_timer.start(active_item_cooldown)
	active_item_used.emit(active_item_cooldown)
	
	SoundManager.play_sfx("stun_sfx", global_position)


func process_move(delta: float) -> void:	
	sprite.update_sprite(input)
	apply_movement(delta, input)

func process_dash(delta: float) -> void:
	apply_movement(delta, input)
	
	if state_timer < 0:
		change_state(IDLE)

func process_heavy_attack_windup(delta: float) -> void:
	current_speed *= heavy_attack_dash_decay
	apply_movement(delta, Vector2.UP.rotated((rotation)))
	
	if state_timer < 0:
		change_state(HEAVY_ATTACK)

func process_heavy_attack(delta: float) -> void:
	current_speed *= heavy_attack_dash_decay
	apply_movement(delta, Vector2.UP.rotated((rotation)))


func stop_dash() -> void:
	current_speed = movement_speed
	sprite.stop_dash()

func stop_light_attack() -> void:
	light_attack_hitbox.disabled = true
	light_attack.visible = false

func stop_heavy_attack() -> void:
	heavy_attack_hitbox.disabled = true
	heavy_attack.visible = false


func update_input() -> void:
	input.x = Input.get_axis("move_left", "move_right")
	input.y = Input.get_axis("move_up", "move_down")
	input = input.normalized()

func apply_movement(delta: float, dir: Vector2) -> void:
	velocity = lerp(velocity, dir * current_speed, acceleration * delta)

func set_facing_dir() -> void:
	var screen_center: Vector2 = get_viewport_rect().size / 2
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	
	var dir: Vector2 = mouse_pos - screen_center
	rotation = dir.angle()+ Vector2.DOWN.angle()

func heal(amount: float) -> void:
	if health >= max_health:
		return
	
	health += amount
	update_health_bar.emit(health)
	
	if health > max_health:
		health = max_health

func get_closest_pickup() -> Area2D:
	var closest = null
	var min_dist = INF
	
	for item in overlapping_pickups:
		var dist = global_position.distance_to(item.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = item
	
	return closest

func deal_damage(area: Area2D, amount: float) -> void:
	var enemy = area.get_parent() as EnemyController
	#print("Damage: ", amount) 
	#Lifesteal
	#NOTE: Might just want to make this flat
	life_stolen = amount * (life_steal/100)
	snappedf(life_stolen,3)
	health += life_stolen
	
	if health > max_health:
		health = max_health
	
	#In case of negative dmg, don't heal the enemies!
	if amount < 0:
		amount = 0
		
	update_health_bar.emit(health)
	
	enemy.take_damage(amount)

func deal_dot_damage(area: Area2D, dot: DotResource) -> void:
	var enemy = area.get_parent() as EnemyController
	
	if dot.dot_tick_damage > 0:
		enemy.take_dot_damage(dot)

func deal_stat_damage(area: Area2D, debuff: DebuffResource) -> void:
	#print("Deal stat damage")
	
	var enemy = area.get_parent() as EnemyController
	
	#print(enemy.current_speed)
	
	if debuff.debuff_stat_damage > 0:
		#print("Take stat damage")
		enemy.take_stat_damage(debuff)

func take_damage(damage:float) -> void:
	instantiate_particles(player_on_damage_particles_scene)
	
	#player_on_damage_particles.restart()
	
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
	
	hit_flash_timer = hit_flash_duration
	GameStats.total_damage_taken += damage
	
	if health <= 0.0:
		die()

func hit_flash() -> void:
	var mat = sprite.material
	if not mat:
		return
	
	var strength = 1.0
	
	# reduce strength after duration * 0.5
	if hit_flash_timer < hit_flash_duration * 0.5:
		strength = hit_flash_timer / (hit_flash_duration * 0.5)
		strength = clamp(strength, 0.0, 1.0)
	
	mat.set_shader_parameter("strength", strength)

func die() -> void:
	game_over.emit()
	queue_free()

func instantiate_particles(particle_scene: PackedScene):
	var particles = particle_scene.instantiate()
	model.add_child(particles)
	particles.finished.connect(_on_particles_finished.bind(particles))
	particles.restart()


func _on_particles_finished(particles_node: Node):
	particles_node.queue_free()

func _on_attack_light_area_entered(area: Area2D) -> void:
	deal_damage(area, attack_light_damage)
	
	if primary_attack_active_dot != null:
		deal_dot_damage(area, primary_attack_active_dot)
	
	if primary_attack_active_debuff != null:
		deal_stat_damage(area, primary_attack_active_debuff)

func _on_attack_heavy_area_entered(area: Area2D) -> void:
	
	deal_damage(area, attack_heavy_damage)
	
	if secondary_attack_active_dot != null:
		deal_dot_damage(area, secondary_attack_active_dot)
		
	if secondary_attack_active_debuff != null:
		deal_stat_damage(area, secondary_attack_active_debuff)

func _on_item_pickup_detector_area_entered(area: Area2D) -> void:
	overlapping_pickups.append(area)

func _on_item_pickup_detector_area_exited(area: Area2D) -> void:
	overlapping_pickups.erase(area)

func _on_health_pickup_detector_area_entered(area: Area2D) -> void:
	# TODO: proper heal amount
	heal(2.0)
	SoundManager.play_sfx("heal", global_position)
	area.queue_free()

func _on_time_alive_timer_timeout() -> void:
	GameStats.time_alive_seconds += 1

func _on_health_regen_timer_timeout() -> void:
	heal(health_regen)

func _on_dash_cooldown_timer_timeout() -> void:
	can_dash = true

func _on_player_sprite_light_attack_finished() -> void:
	change_state(IDLE)

func _on_player_sprite_heavy_attack_finished() -> void:
	change_state(IDLE)

func _on_item_active_cooldown_timer_timeout() -> void:
	can_active_item = true
	pass # Replace with function body.
