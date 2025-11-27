extends Node2D
class_name EnemySpawner

var player: Player = GameManager.player
@export var enemy_list: Array[EnemyPrefab]
@export var mini_boss_list: Array[EnemyPrefab]
@export var boss_list: Array[EnemyPrefab]

@export var wave_cooldown_timer: Timer
@export var wave_cooldown_min := 2.0
@export var wave_cooldown_max := 6.0
@export var min_enemy_spawn_amount := 1
@export var max_enemy_spawn_amount := 2

@export var credits_cooldown_timer: Timer
@export var credits_gain_min := 1
@export var credits_gain_max := 3

@export var boss_cooldown_timer: Timer
@export var boss_cooldown_time := 30.0

var credits := 0.0

@export var diff: DifficultyManager
@export var navigation_region: NavigationRegion2D

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
		
		var enemy = get_random_enemy(enemy_list)
		var cost = enemy.stats.cost
		
		if cost <= credits:
			spawn_enemy(enemy)
			credits -= enemy.stats.cost

func get_spawn_pos(_enemy: EnemyController) -> Vector2:
	var screen_size = get_viewport_rect().size
	
	var side = randi() % 4
	var pos := player.global_position
	
	# TODO: add dynamic offsets to ensure enemies spawning outside the screen
	match side:
		0: # top
			pos.x += randi_range(-screen_size.x / 2, screen_size.x / 2)
			pos.y += -screen_size.y - 100
		1: # bottom
			pos.x += randi_range(-screen_size.x / 2, screen_size.x / 2)
			pos.y += screen_size.y + 100
		2: # left
			pos.x += -screen_size.x - 100
			pos.y += randi_range(-screen_size.y / 2, screen_size.y / 2)
		3: # right
			pos.x += screen_size.x + 100
			pos.y += randi_range(-screen_size.y / 2, screen_size.y / 2)
	
	var nav_map = navigation_region.get_navigation_map()
	var fixed_pos = NavigationServer2D.map_get_closest_point(nav_map, pos)
	return fixed_pos

func get_random_enemy(array: Array) -> EnemyPrefab:
	var choice = randi_range(0, array.size() - 1)
	var prefab = array[choice]
	
	return prefab

func setup_health_bar(enemy: CharacterBody2D) -> void:
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
