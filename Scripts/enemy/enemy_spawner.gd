extends Node2D

@export var player: Node2D
@export var enemy_list: Array[EnemyPrefab] = []
@export var mini_boss_list: Array[EnemyPrefab] = []
@export var boss_list: Array[EnemyPrefab] = []

@export var navigation_region: NavigationRegion2D

@export var difficulty_manager: DifficultyManager

@export var wave_cooldown_timer: Timer
@export var wave_cooldown_min := 2.0
@export var wave_cooldown_max := 6.0
@export var min_enemy_spawn_amount := 2
@export var max_enemy_spawn_amount := 4

@export var credits_cooldown_timer: Timer
@export var credits_gain_min := 2
@export var credits_gain_max := 5

@export var boss_cooldown_timer: Timer
@export var boss_cooldown_time := 30.0

@export var pickupable_item: PackedScene

var credits := 0.0

func spawn_enemy(prefab: EnemyPrefab) -> void:
	var enemy = prefab.scene.instantiate() as EnemyController
	enemy.enemy = prefab.stats.duplicate(true)
	add_child(enemy)
	
	enemy.player = player
	enemy.target_provider = prefab.target_provider
	
	enemy.enemy.max_health *= difficulty_manager.health_mult
	enemy.enemy.health = enemy.enemy.max_health
	enemy.enemy.damage *= difficulty_manager.damage_mult
	
	enemy.global_position = get_spawn_pos(enemy)
	
	setup_health_bar(enemy)
	enemy.enemy_died.connect(_on_enemy_died)

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
	var hud_manager := get_tree().root.get_node("ForestTest/HUD")
	enemy.health_bar = hud_manager.create_enemy_hp_bar(enemy)

func _on_enemy_died(enemy: CharacterBody2D) -> void:
	# TODO: make the enum system cleaner
	# 0 = NORMAL, 1 = MINIBOSS, 2 = BOSS
	if enemy.enemy.type == 2:
		var item = pickupable_item.instantiate()
		add_child(item)
		item.global_position = enemy.global_position
	
	elif randi_range(1,5) == 1:
		var item = pickupable_item.instantiate()
		add_child(item)
		item.global_position = enemy.global_position

func _on_wave_cooldown_timer_timeout() -> void:
	if not player:
		return
	
	var min_enemy_amount = floor(min_enemy_spawn_amount * difficulty_manager.enemy_spawn_amount_mult / 2)
	var max_enemy_amount = floor(max_enemy_spawn_amount * difficulty_manager.enemy_spawn_amount_mult)
	var enemy_amount = randi_range(min_enemy_amount, max_enemy_amount)
	
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
	
	credits += randi_range(credits_gain_min * difficulty_manager.credits_mult, credits_gain_max * difficulty_manager.credits_mult)
	credits_cooldown_timer.start()
