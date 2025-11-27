extends Node

var consumer_items := [
	preload("res://Scripts/items/consumer/Item4.tres"),
	preload("res://Scripts/items/consumer/item5.tres"),
	preload("res://Scripts/items/consumer/item5.tres")
]

var military_items := [
	preload("res://Scripts/items/military/Item2.tres"),
	preload("res://Scripts/items/military/Item2.tres"),
	preload("res://Scripts/items/military/Item2.tres")
]

var prototype_items := [
	preload("res://Scripts/items/prototype/Item1.tres"),
	preload("res://Scripts/items/prototype/Item3.tres"),
	preload("res://Scripts/items/prototype/item6.tres")
]

var type_colors := {
	ItemType.Type.NONE: Color(0.788, 0.788, 0.788),
	ItemType.Type.SURVIVABILITY: Color(0.0, 0.62, 0.465, 1.0),
	ItemType.Type.MOVEMENT: Color(0.085, 0.318, 0.995, 1.0),
	ItemType.Type.UTILITY: Color(0.845, 0.845, 0.0, 1.0),
	ItemType.Type.DAMAGE: Color(0.52, 0.0, 0.0, 1.0),
	ItemType.Type.PRIMARY_ATTACK: Color(0.66, 0.531, 0.231, 1.0),
	ItemType.Type.SECONDARY_ATTACK: Color(0.504, 0.401, 0.16, 1.0),
}

var grade_colors := {
	ItemType.Grade.CONSUMER: Color(0.788, 0.788, 0.788),
	ItemType.Grade.MILITARY: Color(0.4, 0.0, 0.75, 1.0),
	ItemType.Grade.PROTOTYPE: Color(1.0, 0.757, 0.0)
}

var pickupable_item = preload("res://Scenes/pickupable_loot.tscn")
var pickupable_health = preload("res://Scenes/pickupable_health.tscn")

func drop_loot(enemy: EnemyStats) -> bool:
	if randf() > enemy.loot_drop_chance:
		return false
	return true

func get_loot_rarity(enemy: EnemyStats) -> ItemType.Type:
	# set chances
	var consumer_chance = enemy.loot_rarity_weights[0]
	var military_chance = enemy.loot_rarity_weights[1]
	var prototype_chance = enemy.loot_rarity_weights[2]
	
	# pick weighted chance
	var rng = RandomNumberGenerator.new()
	var weights = PackedFloat32Array([consumer_chance, military_chance, prototype_chance])
	var rarity = rng.rand_weighted(weights)
	
	return rarity

func get_items_by_rarity(rarity: ItemType.Grade, amount: int) -> Array:
	var list = []
	match rarity:
		ItemType.Grade.CONSUMER:
			list = consumer_items.duplicate()
		ItemType.Grade.MILITARY:
			list = military_items.duplicate()
		ItemType.Grade.PROTOTYPE:
			list = prototype_items.duplicate()
	
	list.shuffle()
	return list.slice(0, amount)
