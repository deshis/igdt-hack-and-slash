extends Node

var player: Player = null

var open_menu_count := 0

var current_stage: Node = null
var current_stage_ind  := 0
var stage_root: Node = null

var HUD: HudManager = null

var stages := [
	preload("res://Scenes/level/forest_test.tscn"),
	preload("res://Scenes/level/test_area.tscn")
]

func start_game() -> void:
	stage_root = Node.new()
	stage_root.name = "StageRoot"
	add_child(stage_root)
	
	# init player
	player = preload("res://Scenes/player.tscn").instantiate() as Player
	add_child(player)
	
	# init hud
	HUD = preload("res://Scenes/hud.tscn").instantiate() as HudManager
	add_child(HUD)
	InventoryManager.init()
	
	load_stage(0)

func load_stage(num: int) -> void:
	if current_stage and current_stage.is_inside_tree():
		current_stage.queue_free()
	
	if player:
		player.get_parent().remove_child(player)
	
	current_stage = stages[num].instantiate()
	current_stage_ind = num
	
	stage_root.add_child(current_stage)
	
	if player:
		current_stage.add_child(player)
		player.global_position = Vector2.ZERO

func load_next_stage() -> void:
	load_stage(current_stage_ind + 1)

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
