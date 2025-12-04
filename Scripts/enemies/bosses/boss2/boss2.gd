extends EnemyController
class_name Boss2

@export var flee_min_dist_from_player := 350.0
@export var flee_max_dist_from_player := 400.0

@export var flee_duration_min := 1.0
@export var flee_duration_max := 6.0
var flee_duration := 0.0

@export var nanobot: EnemyPrefab

@export var ad_summon_attack_cooldown_max := 2.5
var ad_summon_attack_cooldown := 0.0

@export var nanobot_min_amount := 2
@export var nanobot_max_amount := 5

@export var summon_dist_min := 75.0
@export var summon_dist_max := 150.0

@export var summon_ad_windup_duration := 1.6

@export var face_player_duration := 0.6

@export var boomerang_attack_scene: PackedScene
@export var boomerang_attack_windup_duration := 0.1

var enemy_spawner = null

const FLEE = "flee"
const SUMMON_ADS = "summon_ads"
const FACE_PLAYER = "face_player"
const BOOMERANG_ATTACK = "boomerang_attack"

func _ready() -> void:
	super._ready()
	enemy_spawner = GameManager.current_stage.get_node("EnemySpawner")

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	ad_summon_attack_cooldown -= delta
	flee_duration -= delta
	
	match state:
		FLEE:
			process_flee(delta)
		
		SUMMON_ADS:
			process_summon_ads()
		
		FACE_PLAYER:
			process_face_player(delta)
		
		BOOMERANG_ATTACK:
			process_boomerang_attack()

func change_state(new_state: String, duration := 0.0):
	super.change_state(new_state, duration)
	
	print(state)
	
	match state:
		FLEE:
			flee_duration = randf_range(flee_duration_min, flee_duration_max)
		
		SUMMON_ADS:
			if ad_summon_attack_cooldown > 0:
				change_state(IDLE)
				return
			
			target_provider = TargetSelf.new()
		
		BOOMERANG_ATTACK:
			target_provider = TargetSelf.new()

func process_idle() -> void:
	var rng = randi() % 3
	
	if rng == 0:
		change_state(NAVIGATE)
	elif rng == 1:
		change_state(FLEE)
	else:
		change_state(FACE_PLAYER, face_player_duration)

func process_flee(delta):
	if flee_duration < 0:
		choose_attack()
		return
	
	var dist_to_player = global_position.distance_to(player.global_position)
	
	if dist_to_player < flee_min_dist_from_player:
		target_provider = TargetAwayFromPlayer.new()
	elif dist_to_player >= flee_max_dist_from_player:
		target_provider = TargetPlayer.new()
	
	super.process_navigation(delta)

func process_summon_ads() -> void:
	if state_timer > 0:
		return
	
	ad_summon_attack_cooldown = ad_summon_attack_cooldown_max
	spawn_ads()
	change_state(COOLDOWN, cooldown_duration)

func process_face_player(delta: float) -> void:
	var dir = (player.global_position - global_transform.origin).normalized()
	update_facing_dir(delta, dir)
	
	if state_timer < 0:
		change_state(BOOMERANG_ATTACK, boomerang_attack_windup_duration)

func process_boomerang_attack() -> void:
	if state_timer > 0:
		return
	
	perform_attack(boomerang_attack_scene)
	change_state(COOLDOWN, cooldown_duration)

func choose_attack() -> void:
	if randi() % 2 == 0:
		change_state(SUMMON_ADS, summon_ad_windup_duration)
	else:
		change_state(FACE_PLAYER, face_player_duration)

func spawn_ads() -> void:
	var horde_spawn_pos = get_pos(global_position, summon_dist_min, summon_dist_max)
	var summon_amount = randi_range(nanobot_min_amount, nanobot_max_amount)
	
	for i in range(summon_amount):
		var spawn_pos = get_pos(horde_spawn_pos, 50.0, 75.0)
		enemy_spawner.spawn_enemy(nanobot, spawn_pos)
		
		var wait_timer = randf_range(0.05, 0.3)
		await get_tree().create_timer(wait_timer).timeout

func get_pos(start_pos: Vector2, radius_min: float, radius_max: float) -> Vector2:
	var dist = randf_range(radius_min, radius_max)
	var angle = randf_range(0, TAU)
	var dir = Vector2(cos(angle), sin(angle))
	
	start_pos += dir * dist
	return start_pos

func die() -> void:
	GameManager.boss_killed()
	super.die()
