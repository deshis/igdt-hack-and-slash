extends Resource
class_name EnemyStats

@export var name := "unnamed enemy"
@export var type: EnemyType.Type = EnemyType.Type.NORMAL

@export var loot_drop_chance := 0.2
@export var loot_rarity_weights := {
	ItemType.Grade.CONSUMER: 75,
	ItemType.Grade.MILITARY: 20,
	ItemType.Grade.PROTOTYPE: 5
}

@export var speed := 250.0
@export var max_health := 4.0
var health := max_health
@export var damage := 2.0

@export var cost := 2.0

var acceleration := 20.0
var rotation_speed := 8.0
