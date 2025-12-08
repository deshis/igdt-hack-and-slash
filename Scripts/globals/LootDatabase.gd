extends Node

var consumer_items := [
	preload("res://Scripts/items/consumer/Axe.tres"),
	preload("res://Scripts/items/consumer/Dagger.tres"),
	preload("res://Scripts/items/consumer/DashInverter.tres"),
	preload("res://Scripts/items/consumer/Katana.tres"),
	preload("res://Scripts/items/consumer/Maul.tres"),
	preload("res://Scripts/items/consumer/PlaspringedBoots.tres"),
	preload("res://Scripts/items/consumer/UnderclockedExoskeleton.tres")
]

var military_items := [
	preload("res://Scripts/items/military/ChromaticChassis.tres"),
	preload("res://Scripts/items/military/DashLimiter.tres"),
	preload("res://Scripts/items/military/EnergyConverter.tres"),
	preload("res://Scripts/items/military/Exoskeleton.tres"),
	preload("res://Scripts/items/military/SecondHeart.tres"),
]

var prototype_items := [
	preload("res://Scripts/items/prototype/ArcFlash.tres"),
	preload("res://Scripts/items/prototype/EnergyConverterMk2.tres"),
	preload("res://Scripts/items/prototype/Labrys.tres"),
	preload("res://Scripts/items/prototype/OverclockedExoskeleton.tres"),
	preload("res://Scripts/items/prototype/SpectriteChassis.tres"),
	preload("res://Scripts/items/prototype/Statstick.tres"),
	
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

var enemy_loot_table = preload("res://Scripts/globals/loot_table_enemy.tres")
var aug_enemy_loot_table = preload("res://Scripts/globals/loot_table_aug_enemy.tres")
var boss_loot_table = preload("res://Scripts/globals/loot_table_boss.tres")

var pickupable_item = preload("res://Scenes/pickupable_loot.tscn")
var pickupable_health = preload("res://Scenes/pickupable_health.tscn")

func drop_loot(enemy: EnemyController) -> void:
	var loot_table = get_loot_table(enemy.enemy)
	var player = GameManager.player
	
	# ITEM
	if randf() < loot_table.loot_drop_chance:
		var loot = pickupable_item.instantiate()
		GameManager.stage_root.add_child(loot)
		loot.global_position = enemy.global_position
		loot.set_loot(LootDatabase.get_loot_rarity(loot_table.loot_rarity_weights))
		
		var dir = player.global_position.direction_to(enemy.global_position)
		loot.setup(player, dir)
	
	# HEALTH
	for i in range(loot_table.health_drop_amount):
		if randf() < loot_table.health_drop_chance:
			var pickup = LootDatabase.pickupable_health.instantiate()
			GameManager.stage_root.add_child(pickup)
			pickup.global_position = enemy.global_position

			var dir = player.global_position.direction_to(enemy.global_position)
			pickup.setup(player, dir)


func get_loot_table(enemy: EnemyStats) -> LootTable:
	match enemy.type:
		EnemyType.Type.NORMAL:
			return enemy_loot_table
		
		EnemyType.Type.AUGMENTED:
			return aug_enemy_loot_table
		
		EnemyType.Type.BOSS:
			return boss_loot_table
	
	return null

func get_loot_rarity(loot_weights: Dictionary) -> ItemType.Type:
	# set chances
	var consumer_chance = loot_weights.get("consumer")
	var military_chance = loot_weights.get("military")
	var prototype_chance = loot_weights.get("prototype")
	
	# pick weighted chance
	var rng = RandomNumberGenerator.new()
	var weights = PackedFloat32Array([consumer_chance, military_chance, prototype_chance])
	var rarity = rng.rand_weighted(weights)
	
	return ItemType.Type.values()[rarity]

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
