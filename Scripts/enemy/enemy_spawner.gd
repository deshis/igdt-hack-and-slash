extends Node2D

@export var player: Node2D
@export var enemy_list: Array[EnemyPrefab] = []
@export var mini_boss_list: Array[EnemyPrefab] = []
@export var boss_list: Array[EnemyPrefab] = []

@export var navigation_region: NavigationRegion2D

@export var wave_cooldown_timer: Timer
@export var wave_cooldown_min := 2.0
@export var wave_cooldown_max := 6.0

@export var boss_cooldown_timer: Timer
@export var boss_cooldown_time := 30.0

var credits := 0.0

func spawn_enemy(prefab: EnemyPrefab) -> void:
	var enemy = prefab.scene.instantiate() as EnemyController
	enemy.enemy = prefab.stats.duplicate(true)
	add_child(enemy)
	
	enemy.player = player
	enemy.target_provider = prefab.target_provider
	
	var spawn_pos = get_spawn_pos(enemy)
	enemy.global_position = spawn_pos
	

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

func _on_wave_cooldown_timer_timeout() -> void:
	if player:
		credits += randi_range(2, 5)
		var enemy_amount = randi_range(2, 6)
		spawn_wave_of_enemies(enemy_amount)
		
		var cooldown = randf_range(wave_cooldown_min, wave_cooldown_max)
		wave_cooldown_timer.start(cooldown)


func _on_boss_cooldown_timer_timeout() -> void:
	var boss = get_random_enemy(boss_list)
	spawn_enemy(boss)
	
	var cost = boss.stats.cost
	credits -= cost
