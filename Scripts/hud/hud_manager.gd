extends Node
class_name HudManager

var player: Player = GameManager.player

@onready var inventory = $Inventory
@onready var cooldowns = $SkillCooldowns
@onready var health_bars := $HPBars
@onready var health_bar = $HPBars/Player
@onready var game_over_screen: Control = $GameOverScreen

func _ready() -> void:
	if player:
		health_bar.setup(player, player.health, player.max_health)
		game_over_screen.setup(player)


func create_enemy_hp_bar(enemy: CharacterBody2D) -> Control:
	var health_bar = preload("res://Scenes/HPBar.tscn").instantiate()
	health_bar.is_static = false
	health_bars.add_child(health_bar)
	health_bar.setup(enemy, enemy.enemy.health, enemy.enemy.max_health)
	
	return health_bar
