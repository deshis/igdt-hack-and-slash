extends Node2D

@export var player: Node2D
@export var enemy_list: Array[EnemyPrefab] = []
@export var navigation_region: NavigationRegion2D

@export var cooldown_timer: Timer
@export var wave_cooldown_min = 2
@export var wave_cooldown_max = 6
var credits := 0

func spawn_enemy(prefab: EnemyPrefab) -> void:
	var enemy = prefab.scene.instantiate() as EnemyController
	enemy.enemy = prefab.stats.duplicate(true)
	add_child(enemy)
	
	enemy.player = player
	enemy.target_provider = prefab.target_provider
	
	var spawn_pos = get_spawn_pos(enemy)
	enemy.global_position = spawn_pos

func spawn_wave_of_enemies() -> void:
	var credits_to_use = randi_range(0, credits)
	
	while credits_to_use > 0:
		var choice = randi_range(0, enemy_list.size() - 1)
		var prefab = enemy_list[choice]
		spawn_enemy(prefab)
		
		credits_to_use -= prefab.stats.cost
		credits -= prefab.stats.cost

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

func _on_cooldown_timer_timeout() -> void:
	if player:
		credits += randi_range(1, 4)
		spawn_wave_of_enemies()
		
		var cooldown = randi_range(wave_cooldown_min, wave_cooldown_max)
		cooldown_timer.start(cooldown)
