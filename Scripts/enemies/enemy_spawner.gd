extends Node3D
class_name EnemySpawner

var player: Player = GameManager.player
@export var enemy_list: Array[EnemyPrefab]
@export var augmented_list: Array[EnemyPrefab]
@export var boss_list: Array[EnemyPrefab]

@export var wave_cooldown_timer: Timer
@export var wave_cooldown_min := 2.0
@export var wave_cooldown_max := 6.0
@export var min_enemy_spawn_amount := 1
@export var max_enemy_spawn_amount := 2

@export var credits_cooldown_timer: Timer
@export var credits_gain_min := 1
@export var credits_gain_max := 3

@export var augment_enemy_chance := 0.15

@export var boss_cooldown_timer: Timer
@export var boss_cooldown_time := 120.0

var credits := 0.0

@export var diff: DifficultyManager
@export var navigation_region: NavigationRegion3D

func start_spawner() -> void:
	boss_cooldown_timer.start(boss_cooldown_time)
	wave_cooldown_timer.start()
	credits_cooldown_timer.start()

func spawn_enemy(prefab: EnemyPrefab) -> void:
	var enemy = prefab.scene.instantiate() as EnemyController
	enemy.enemy = prefab.stats.duplicate(true)
	add_child(enemy)
	
	enemy.player = player
	enemy.target_provider = prefab.target_provider if prefab.target_provider else TargetPlayer.new()
	
	enemy.enemy.setup(diff.difficulty_level)
	enemy.global_position = get_spawn_pos(enemy)
	
	setup_health_bar(enemy)

func spawn_wave_of_enemies(amount: int) -> void:
	for i in range(amount):
		if credits == 0:
			return
		
		var enemy = null
		var augment_chance = augment_enemy_chance + diff.difficulty * diff.augment_enemy_chance_per_level
		if randf() < augment_chance:
			enemy = get_random_enemy(augmented_list)
		else:
			enemy = get_random_enemy(enemy_list)
		
		var cost = enemy.stats.cost
		
		if cost <= credits:
			spawn_enemy(enemy)
			credits -= enemy.stats.cost

func get_spawn_pos(_enemy: EnemyController) -> Vector3:
	var vp_size = get_viewport().get_size()
	
	var screen_x
	var screen_y
	
	match randi() % 4:
		0:  # left
			screen_x = -0.1
			screen_y = randf()
		1:  # right
			screen_x = 1.1
			screen_y = randf()
		2:  # bottom
			screen_x = randf()
			screen_y = -0.1
		3:  # top
			screen_x = randf()
			screen_y = 1.1
	
	var pos = get_viewport().get_camera_3d().project_position(Vector2(screen_x, screen_y) * Vector2(vp_size.x, vp_size.y), 10)
	var nav_map = navigation_region.get_navigation_map()
	var fixed_pos = NavigationServer3D.map_get_closest_point(nav_map, pos)
	return fixed_pos

func get_random_enemy(array: Array) -> EnemyPrefab:
	var choice = randi_range(0, array.size() - 1)
	var prefab = array[choice]
	
	return prefab

func setup_health_bar(enemy: CharacterBody3D) -> void:
	enemy.health_bar = GameManager.HUD.create_enemy_hp_bar(enemy)

func _on_wave_cooldown_timer_timeout() -> void:
	if not player:
		return
	
	var min_amount = floor(min_enemy_spawn_amount + (diff.difficulty_level * diff.enemy_spawn_amount_per_level / 2))
	var max_amount = floor(max_enemy_spawn_amount + diff.difficulty_level * diff.enemy_spawn_amount_per_level)
	var enemy_amount = randi_range(min_amount, max_amount)
	
	spawn_wave_of_enemies(enemy_amount)
	
	var cooldown = randf_range(wave_cooldown_min, wave_cooldown_max)
	wave_cooldown_timer.start(cooldown)

func _on_boss_cooldown_timer_timeout() -> void:
	if not player:
		return
	
	var boss = get_random_enemy(boss_list)
	spawn_enemy(boss)
	
	var cost = boss.stats.cost
	credits -= cost


func _on_credits_cooldown_timer_timeout() -> void:
	if not player:
		return
	
	var min_credits = credits_gain_min + diff.difficulty_level * diff.credits_per_level
	var max_credits = credits_gain_max + diff.difficulty_level * diff.credits_per_level
	credits += randi_range(min_credits, max_credits)
	credits_cooldown_timer.start()
