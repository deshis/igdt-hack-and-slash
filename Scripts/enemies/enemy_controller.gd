extends CharacterBody2D
class_name EnemyController

# HEALTH BAR
signal update_health_bar(float)
var health_bar

# ENEMY STATS
var enemy: EnemyStats
var target_provider: TargetProvider
@onready var current_speed := enemy.speed
@export var nav_agent: NavigationAgent2D

@onready var player: Player = GameManager.player

# PARTICLES
var hit_particles_scene = preload("res://Scenes/enemy/particles/on_hit_particles.tscn")
var electric_dot_particles_scene = preload("res://Scenes/enemy/particles/electric_dot_particles.tscn")
var freeze_shatter_particles_scene = preload("res://Scenes/enemy/particles/freeze_shatter_particles.tscn")

var active_freeze_particles_scene = preload("res://Scenes/enemy/particles/freeze_particles.tscn")
#var active_freeze_particles: Node2D = null
var hit_flash_duration := 0.15
var hit_flash_timer := 0.0
@onready var death_particles: CPUParticles2D = $Particles/OnDeathParticles
@onready var death_particles2: CPUParticles2D = $Particles/OnDeathParticles/OnDeathParticles2

var debuff_timer: Timer
var dot_timer: Timer

var active_dots: DotResource = null
var active_stat_debuffs: DebuffResource = null
var dot_tick_rate := 1.5
var remaining_dot_duration := 0.0
var current_tick_damage := 0.0
var current_debuff_tick_rate := 0.0
var current_dot_tick_rate := 0.0

var current_stat_damage := 0.0
var remaining_debuff_duration := 0.0
var enemy_frozen := false

# 3D MODEL
var animator = null
@export var model_view: Node3D = null
@export var camera_point: Node3D = null
@export var sprite: Sprite2D = null

# ATTACK
@export var attack: PackedScene = null
@export var attack_windup_duration := 0.6
@export var attack_range := 200.0
@export var cooldown_duration := 1.0

var active_attacks: Array[Node2D] = []

# STATE MACHINE
var state = "idle"
var state_timer := 0.0

const IDLE = "idle"
const NAVIGATE = "navigate"
const ATTACK = "attack"
const STUN = "stun"
const COOLDOWN = "cooldown"

func _init() -> void:
	debuff_timer = Timer.new()
	dot_timer = Timer.new()

func _ready() -> void:
	sprite.material = sprite.material.duplicate()
	nav_agent.path_desired_distance = attack_range
	
	if model_view:
		animator = camera_point.get_node("AnimationPlayer")
		model_view.position = Vector3(randf()*1e6, randf()*1e6, randf()*1e6)
		
	dot_timer = Timer.new()
	dot_timer.timeout.connect(_on_dot_tick) 
	add_child(dot_timer)
	
	debuff_timer.timeout.connect(_on_debuff_tick) 
	add_child(debuff_timer)
	
	change_state(IDLE)

func _physics_process(delta: float) -> void:
	if not player or not target_provider:
		return
	
	# model stuff
	if model_view:
		sprite.rotation = -rotation
		camera_point.rotation.y = -deg_to_rad(round(rad_to_deg(rotation+PI) / 5.0) * 5.0)
	
	state_timer -= delta
	
	match state:
		IDLE:
			process_idle()
		
		NAVIGATE:
			process_navigation(delta)
		
		ATTACK:
			process_attack()
		
		STUN:
			if state_timer <= 0:
				change_state(IDLE)
		
		COOLDOWN:
			if state_timer <= 0:
				change_state(IDLE)
	
	if hit_flash_timer > 0:
		hit_flash_timer -= delta
		hit_flash()


func change_state(new_state: String, duration := 0.0):
	state = new_state
	state_timer = duration
	
	match state:
		NAVIGATE:
			target_provider = TargetPlayer.new()
		
		STUN:
			for instance in active_attacks:
				instance.remove_attack()

func process_idle() -> void:
	change_state(NAVIGATE)

func process_attack() -> void:
	if state_timer > 0:
		return
	
	perform_attack(attack)
	change_state(COOLDOWN, cooldown_duration)

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

func perform_attack(attack_scene: PackedScene, offset: Vector2 = Vector2.ZERO) -> void:
	var instance = attack_scene.instantiate()
	instance.offset = instance.offset if offset == Vector2.ZERO else offset
	add_child(instance)
	instance.attack_hit.connect(_on_attack_area_area_entered)
	instance.attack_removed.connect(_on_attack_removed)
	
	active_attacks.append(instance)

func take_dot_damage(dot: DotResource) -> void:

	#stacking dots would be nice
	active_dots = dot
	
	remaining_dot_duration = dot.dot_duration
	current_tick_damage = dot.dot_tick_damage
	current_dot_tick_rate = dot.dot_tick_rate
	
	dot_timer.set_wait_time(current_dot_tick_rate)
	
	if dot.dot_duration <= 0.0:
		dot_timer.stop()
		dot.dot_tick_damage = 0
		dot.dot_duration = 0
		return
			
	if enemy.health <= 0.0:
		die()
		return
		
	dot_timer.start()
			
func _on_dot_tick() -> void:
	
	if remaining_dot_duration > 0.0:

		enemy.health -= current_tick_damage
		update_health_bar.emit(enemy.health)
		hit_flash_timer = hit_flash_duration
		SoundManager.play_sfx("dot_sfx", global_position)  #Might want DoT SFX here, maybe even separate depending on DoT (From resource)
		
		if active_dots.particle_scene:
			instantiate_particles(active_dots.particle_scene)
			
		remaining_dot_duration -= current_dot_tick_rate
		
		GameStats.total_damage_dealt += current_tick_damage
		
		if remaining_dot_duration <= 0.0:
			dot_timer.stop()
			remaining_dot_duration = 0
			current_tick_damage = 0
			active_dots = null
			
		if enemy.health <= 0.0:
			die()
			return
		
		dot_timer.start()
		
func take_stat_damage(debuff: DebuffResource) -> void:
	active_stat_debuffs = debuff
	#get_parent().take_stat_damage(debuff)
	
	print("Taking stat damage")

	#active_stat_debuffs = debuff
	
	remaining_debuff_duration = debuff.debuff_duration
	current_stat_damage = debuff.debuff_stat_damage
	current_debuff_tick_rate = debuff.debuff_tick_rate
	
	apply_debuff_effect(debuff)
	
	debuff_timer.set_wait_time(current_debuff_tick_rate)
	
	if not debuff_timer.is_stopped():
		debuff_timer.stop()

	debuff_timer.start()
			
	if enemy.health <= 0.0:
		die()
		return
		
	debuff_timer.start()
	
func apply_debuff_effect(debuff: DebuffResource) -> void:
	print("Applying debuff")
	match debuff.debuff_type:
		DebuffResource.DebuffType.STUN:
			if active_stat_debuffs.particle_scene:
				instantiate_particles(active_stat_debuffs.particle_scene)
				
			SoundManager.play_sfx("stun_sfx", global_position)
			
			change_state(STUN, remaining_debuff_duration)
		DebuffResource.DebuffType.FREEZE:
			if active_stat_debuffs.particle_scene:
				#First plays the freeze effect, then thawing effect once , as long as the debuff tick rate matches the debuff duration.
				instantiate_particles(active_freeze_particles_scene)
				
			SoundManager.play_sfx("freeze_sfx", global_position)
			enemy_frozen = true
			
			change_state(COOLDOWN, remaining_debuff_duration)
			
func remove_debuff_effect(debuff: DebuffResource) -> void:
	if debuff:
		match debuff.debuff_type:
			DebuffResource.DebuffType.STUN:
				pass
				
			DebuffResource.DebuffType.FREEZE:
				enemy_frozen = false

func _on_debuff_tick() -> void:

	if remaining_debuff_duration > 0.0:
		print("Debuff applied: ", remaining_debuff_duration, " seconds left")
		
		if active_stat_debuffs.particle_scene:
			instantiate_particles(active_stat_debuffs.particle_scene)
		
		remaining_debuff_duration -= current_debuff_tick_rate
		
		#if active_stat_debuffs.debuff_stat_damage > 0:
			#enemy.take_stat_damage(active_stat_debuffs)
		
		#change_state(COOLDOWN, remaining_debuff_duration)
		
		if remaining_debuff_duration <= 0.0:
			remove_debuff_effect(active_stat_debuffs)
			debuff_timer.stop()
			remaining_debuff_duration = 0
			current_stat_damage = 0
			active_stat_debuffs = null
			
		if enemy.health <= 0.0:
			die()
			return
		
		debuff_timer.start()
			

func take_damage(damage:float) -> void:
	if enemy_frozen:
		enemy_frozen = false
		shatter_ice()
		
	enemy.health -= damage
	update_health_bar.emit(enemy.health)
	hit_flash_timer = hit_flash_duration
	SoundManager.play_sfx("hit", global_position)
	
	instantiate_particles(hit_particles_scene)
	
	GameStats.total_damage_dealt += damage
	
	if enemy.health <= 0.0:
		die()

func die() -> void:
	SoundManager.play_sfx("enemy_die", global_position)
	
	#Death particles here
	#TODO: clean these
	if death_particles:
		death_particles.get_parent().remove_child(death_particles)
		get_tree().get_root().add_child(death_particles)
		death_particles.global_position = global_position
		death_particles.restart()
		death_particles2.restart()
		
	if health_bar:
		health_bar.queue_free()
	
	GameStats.enemies_killed +=1
	drop_health_pickup()
	drop_loot()
	queue_free()
	
func shatter_ice() -> void:

	print("Ice shattered")

	#get_node("freeze_particles").process_material.set("lifetime", 1 )
	#Reset everything
	enemy_frozen = false
	remove_debuff_effect(active_stat_debuffs)
	debuff_timer.stop()
	remaining_debuff_duration = 0
	current_stat_damage = 0
	active_stat_debuffs = null
	
	#Interrupt the state
	if state_timer:
		state_timer = 0
		
	instantiate_particles(freeze_shatter_particles_scene)
	
func instantiate_particles(particle_scene: PackedScene):
	var particles = particle_scene.instantiate()
	
	get_parent().add_child(particles)
	particles.global_position = global_position
	
	particles.finished.connect(_on_particles_finished.bind(particles))
	
	particles.restart()

func _on_particles_finished(particles_node: Node):
	particles_node.queue_free()

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

func drop_loot() -> void:
	if LootDatabase.drop_loot(enemy):
		var loot = LootDatabase.pickupable_item.instantiate()
		GameManager.stage_root.add_child(loot)
		loot.global_position = global_position
		loot.set_loot(LootDatabase.get_loot_rarity(enemy))
		
		var dir = player.global_position.direction_to(global_position)
		loot.setup(player, dir)

func drop_health_pickup() -> void:
	# TODO: proper health drop chance
	if randi() % 3 == 0:
		var pickup = LootDatabase.pickupable_health.instantiate()
		GameManager.stage_root.add_child(pickup)
		pickup.global_position = global_position
		
		var dir = player.global_position.direction_to(global_position)
		pickup.setup(player, dir)

func _on_attack_area_area_entered(_area: Area2D, damage: float = enemy.damage) -> void:
	player.take_damage(damage)
	GameStats.player_last_hit_by=enemy.name

func _on_navigation_agent_2d_target_reached() -> void:
	change_state(ATTACK, attack_windup_duration)

func _on_attack_removed(node: Node2D) -> void:
	active_attacks.erase(node)
