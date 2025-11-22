extends Node
class_name HudManager

@export var player: Player

@onready var inventory = $Inventory
@onready var cooldowns = $SkillCooldowns
@onready var health_bars := $HPBars
@onready var health_bar = $HPBars/Player

func _ready() -> void:
	inventory.setup_inventory(player)
	cooldowns.setup(player)
	health_bar.setup(player, player.health, player.max_health)


func create_enemy_hp_bar(enemy: CharacterBody2D) -> Control:
	var health_bar = preload("res://Scenes/HPBar.tscn").instantiate()
	health_bar.is_static = false
	health_bars.add_child(health_bar)
	health_bar.setup(enemy, enemy.enemy.health, enemy.enemy.max_health)
	
	return health_bar
