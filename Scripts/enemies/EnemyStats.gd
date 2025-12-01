extends Resource
class_name EnemyStats

@export var name := "unnamed enemy"
@export var type: EnemyType.Type = EnemyType.Type.NORMAL

var loot_drop_chance := 0.0
var loot_rarity_weights = [0, 0, 0]

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
			loot_drop_chance = LootDatabase.normal_drop_chance
			loot_rarity_weights = LootDatabase.normal_weights
		EnemyType.Type.AUGMENTED:
			loot_drop_chance = LootDatabase.augmented_drop_chance
			loot_rarity_weights = LootDatabase.augmented_weights
		EnemyType.Type.BOSS:
			loot_drop_chance = LootDatabase.boss_drop_chance
			loot_rarity_weights = LootDatabase.boss_weights
