extends Node

var player: Player = null

var open_menu_count := 0

var current_stage: Node = null
var current_stage_ind  := 0
var stage_root: Node = null

var HUD: HudManager = null

func _ready() -> void:
	# init player
	player = preload("res://Scenes/player/player.tscn").instantiate() as Player
	add_child(player)


var stages := [
	preload("res://Scenes/forest/forest_test_variety.tscn")
]


func start_game() -> void:
	
	stage_root = Node.new()
	stage_root.name = "StageRoot"
	add_child(stage_root)
	
	# init hud
	HUD = preload("res://Scenes/hud.tscn").instantiate() as HudManager
	add_child(HUD)
	
	load_stage(0)
	
	InventoryManager.init()

func load_stage(num: int) -> void:
	for child in stage_root.get_children():
		child.queue_free()
	
	for child in HUD.get_node("HPBars").get_children():
		child.queue_free()
	
	GameStats.stages_cleared = num
	
	current_stage = stages[num].instantiate()
	current_stage_ind = num
	
	stage_root.add_child(current_stage)
	player.global_position = Vector3.ZERO

func load_next_stage() -> void:
	load_stage(current_stage_ind + 1)

func boss_killed() -> void:
	await get_tree().create_timer(10).timeout
	load_next_stage()

func restart() -> void:
	for child in get_children():
		child.queue_free()
	
	InventoryManager.reset_inventory()
	start_game()

func open_menu() -> void:
	open_menu_count += 1
	get_tree().paused = true

func close_menu() -> void:
	open_menu_count -= 1
	if open_menu_count == 0:
		get_tree().paused = false

func set_menu(status: bool) -> void:
	match status:
		true: open_menu()
		false: close_menu()


func quit_to_menu()->void:
	open_menu_count = 0
	get_tree().paused = false
	
	for child in get_children():
		child.queue_free()
	
	var main_menu = preload("res://Scenes/main_menu.tscn").instantiate()
	add_child(main_menu)


func start_game_from_main_menu()->void:
	for child in get_children():
		child.queue_free()
	
	player = preload("res://Scenes/player/player.tscn").instantiate() as Player
	add_child(player)
	
	start_game()
