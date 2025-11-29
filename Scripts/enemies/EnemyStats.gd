extends Resource
class_name EnemyStats

@export var name := "unnamed enemy"
@export var type: EnemyType.Type = EnemyType.Type.NORMAL

var loot_drop_chance := 0.0
var loot_rarity_weights = [0, 0, 0]

var normal_drop_chance := 0.08
var miniboss_drop_chance := 0.2
var boss_drop_chance := 1.0

var normal_weights := [100, 0, 0]
var miniboss_weights := [75, 25, 0]
var boss_weights := [0, 25, 75]

@export var speed := 250.0
@export var max_health := 4.0
var health := max_health
@export var damage := 2.0
@export var cost := 2.0

@export var health_per_level := 0.2
@export var damage_per_level := 0.1

var acceleration := 20.0
var rotation_speed := 8.0

func setup(difficulty_level: int) -> void:
	max_health += difficulty_level * health_per_level
	health = max_health
	damage += difficulty_level * damage_per_level
	
	# set loot drops
	match type:
		EnemyType.Type.NORMAL:
			loot_drop_chance = normal_drop_chance
			loot_rarity_weights = normal_weights
		EnemyType.Type.MINIBOSS:
			loot_drop_chance = miniboss_drop_chance
			loot_rarity_weights = miniboss_weights
		EnemyType.Type.BOSS:
			loot_drop_chance = boss_drop_chance
			loot_rarity_weights = boss_weights
