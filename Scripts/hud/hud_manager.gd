extends Node

@export var player: Player

@onready var inventory = $Inventory
@onready var cooldowns = $SkillCooldowns
@onready var health_bar = $HPBar

func _ready() -> void:
	inventory.setup_inventory(player)
	cooldowns.setup(player)
	health_bar.setup(player)
