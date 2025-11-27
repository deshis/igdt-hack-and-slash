extends CharacterBody2D
class_name EnemyController

signal update_health_bar(float)
var health_bar

@export var enemy: EnemyStats
var target_provider: TargetProvider
@onready var sprite = $Sprite2D

@export var nav_agent: NavigationAgent2D

@export var attack_area: Area2D
@export var attack_area_hitbox: CollisionShape2D

@export var wait_before_attack_timer: Timer
@export var attack_length_timer: Timer
@export var wait_after_attack_timer: Timer

@onready var dot_timer: Timer = $Timers/DotDurationTimer
#@onready var hit_particles: CPUParticles2D = $Particles/OnHitParticles
var hit_particles_scene = preload("res://Scenes/enemy/particles/on_hit_particles.tscn")
var electric_dot_particles_scene = preload("res://Scenes/enemy/particles/electric_dot_particles.tscn")

@onready var death_particles: CPUParticles2D = $Particles/OnDeathParticles
@onready var death_particles2: CPUParticles2D = $Particles/OnDeathParticles/OnDeathParticles2

var dot_tick_rate := 1.5
var remaining_dot_duration := 0.0
var current_tick_damage := 0.0
var current_tick_rate := 0.0

@onready var player: Player = GameManager.player
var target: Node2D
var is_navigating := true
var target_reached := false

@onready var current_speed := enemy.speed

func _ready() -> void:
	attack_area_hitbox.disabled = true
	sprite.material = sprite.material.duplicate()
	
	dot_timer = Timer.new()
	dot_timer.timeout.connect(_on_dot_tick) 
	add_child(dot_timer)
	
func _physics_process(delta: float) -> void:
	if not player or not target_provider:
		return
	
	if is_navigating:
		process_navigation(delta)

func process_navigation(delta: float) -> void:
	var new_target_pos = target_provider.get_target(self)
	
	if global_position.distance_to(new_target_pos) > 1.0:
		nav_agent.set_target_position(new_target_pos)
	
	if nav_agent.is_navigation_finished():
		return
	
	var next_pos = nav_agent.get_next_path_position()
	var dir = (next_pos - global_transform.origin).normalized()
	
	update_facing_dir(delta, dir)
	apply_movement(delta, dir)

func apply_movement(delta: float, dir: Vector2) -> void:
	velocity = lerp(velocity, dir * current_speed, enemy.acceleration * delta)
	move_and_slide()

func update_facing_dir(delta: float, dir: Vector2) -> void:
	var target_angle = dir.angle() + Vector2.DOWN.angle()
	rotation = lerp_angle(rotation, target_angle, enemy.rotation_speed * delta)

func perform_attack() -> void:
	if not attack_length_timer:
		_on_wait_after_attack_timer_timeout()
		return
	
	attack_area.visible = true
	attack_area_hitbox.disabled = false
	
	attack_length_timer.start()
	
func take_dot_damage(dot_tick_damage:float, dot_duration:float, tick_rate:float) -> void:
	print("dot stats: ","dot dmg: ", dot_tick_damage,"dot duration: ", dot_duration,"dot tick rate: ",tick_rate) 
	
	remaining_dot_duration = dot_duration
	current_tick_damage = dot_tick_damage
	current_tick_rate = tick_rate
	
	dot_timer.set_wait_time(current_tick_rate)
	
	if dot_duration <= 0.0:
		dot_timer.stop()
		dot_tick_damage = 0
		dot_duration = 0
		return
			
	if enemy.health <= 0.0:
		die()
		return
		
	dot_timer.start()
			
func _on_dot_tick() -> void:
	
	if remaining_dot_duration > 0.0:
		#print("dealing dot dmg: ",current_tick_damage) 
		enemy.health -= current_tick_damage
		update_health_bar.emit(enemy.health)
		hit_flash()
		SoundManager.play_sfx("dot_sfx", global_position)  #Might want DoT SFX here, maybe even separate depending on DoT (From resource)
		
		remaining_dot_duration -= current_tick_rate
		
		#NOTE: Different particles for different DoT?
		var electric_dot_particles = electric_dot_particles_scene.instantiate()
		get_parent().add_child(electric_dot_particles)
		electric_dot_particles.global_position = global_position
		
		electric_dot_particles.restart()
		
		GameStats.total_damage_dealt += current_tick_damage
		
		if remaining_dot_duration <= 0.0:
			dot_timer.stop()
			remaining_dot_duration = 0
			current_tick_damage = 0
			
		if enemy.health <= 0.0:
			die()
			return
		
		dot_timer.start()
			
			
func take_damage(damage:float) -> void:
	enemy.health -= damage
	update_health_bar.emit(enemy.health)
	hit_flash()
	SoundManager.play_sfx("hit", global_position)
	
	var hit_particles = hit_particles_scene.instantiate()
	get_parent().add_child(hit_particles)
	hit_particles.global_position = global_position
	
	hit_particles.restart()
	GameStats.total_damage_dealt += damage
	
	if enemy.health <= 0.0:
		die()

func die() -> void:
	SoundManager.play_sfx("enemy_die", global_position)
	
	#Death particles here
	if death_particles:
		#detaching the particles from the enemy so they don't get deleted as well
		death_particles.get_parent().remove_child(death_particles)
		get_tree().get_root().add_child(death_particles)
		death_particles.global_position = global_position

		death_particles.restart()
		death_particles2.restart()
		#TODO: CLEAN THE PARTICLE NODES AS WELL
	
	if health_bar:
		health_bar.queue_free()
	
	GameStats.enemies_killed +=1
	drop_health_pickup()
	drop_loot()
	queue_free()

func hit_flash() -> void:
	var mat = sprite.material
	if not mat:
		return
	
	mat.set_shader_parameter("strength", 1.0)
	await get_tree().create_timer(0.1).timeout
	mat.set_shader_parameter("strength", 0.0)

func drop_loot() -> void:
	if LootDatabase.drop_loot(enemy):
		var loot = LootDatabase.pickupable_item.instantiate()
		get_tree().root.add_child(loot)
		loot.global_position = global_position
		loot.set_loot(LootDatabase.get_loot_rarity(enemy))
		
		var dir = player.global_position.direction_to(global_position)
		loot.setup(player, dir)

func drop_health_pickup() -> void:
	# TODO: proper health drop chance
	if randi() % 3 == 0:
		var pickup = LootDatabase.pickupable_health.instantiate()
		get_tree().root.add_child(pickup)
		pickup.global_position = global_position
		
		var dir = player.global_position.direction_to(global_position)
		pickup.setup(player, dir)

func _on_attack_area_area_entered(_area: Area2D) -> void:
	player.take_damage(enemy.damage)
	GameStats.player_last_hit_by=self

func _on_navigation_agent_2d_target_reached() -> void:
	is_navigating = false
	
	if not wait_before_attack_timer:
		perform_attack()
		return
	
	target_provider = TargetSelf.new()
	wait_before_attack_timer.start()

func _on_wait_before_attack_timer_timeout() -> void:
	perform_attack()

func _on_attack_length_timer_timeout() -> void:
	if not wait_after_attack_timer:
		_on_wait_after_attack_timer_timeout()
		return
	
	attack_area.visible = false
	attack_area_hitbox.disabled = true
	
	wait_after_attack_timer.start()

func _on_wait_after_attack_timer_timeout() -> void:
	target_provider = TargetPlayer.new()
	is_navigating = true
	
