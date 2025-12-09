extends Resource
class_name Stats 

@export var stat_type: Stat = Stat.HEALTH
@export var value: float = 0.0
@export var dot_resource: DotResource
@export var debuff_resource: DebuffResource

signal update_health_bar

var primary
var secondary

#NOTE: Might want a separate damage stat for clarity?
#NOTE: Bloated! Too bad.
enum Stat { 
	HEALTH, 
	HEALTH_REGEN,
	FLAT_DAMAGE_REDUCTION,
	PERCENT_DAMAGE_REDUCTION,
	MOVEMENT_SPEED, 
	
	LIGHT_DAMAGE,
	HEAVY_DAMAGE,
	
	LIGHT_COOLDOWN,
	HEAVY_COOLDOWN,
	
	LIGHT_SIZE_X,
	LIGHT_SIZE_Y,
	HEAVY_SIZE_X,
	HEAVY_SIZE_Y,
	
	LIFESTEAL,
	DOT_EFFECT,
	PRIMARY_CHECK,
	DEBUFF_EFFECT,
	DASH_COOLDOWN,
	DASH_LENGTH,
	DASH_SPEED,
	
	CRIT_CHANCE,
	THORNS_PERCENT,
	
	LOOT_DROP_CHANCE,
	LOOT_RARITY_INC_PERCENT,
	PICKUP_LOOT_AMOUNT,
	}

func apply_effect(player) -> void:
	
	match stat_type:
		
		Stat.FLAT_DAMAGE_REDUCTION:
			player.flat_damage_reduction += value
		Stat.PERCENT_DAMAGE_REDUCTION:
			player.percent_damage_reduction += value
			
		Stat.HEALTH:
			# player.health += value
			player.max_health += value
			player.emit_signal("update_health_bar", player.health, player.max_health)
		Stat.HEALTH_REGEN:
			player.health_regen += value
		Stat.MOVEMENT_SPEED:
			player.current_speed += value
			player.movement_speed += value
			
		Stat.LIGHT_COOLDOWN:
			player.light_attack_speed_scale += value
			
			#Might still be useful for the hitbox lingering? probably not.
			#player.light_attack_cooldown += value
		Stat.HEAVY_COOLDOWN:
			player.heavy_attack_cooldown += value

		Stat.LIGHT_DAMAGE:
			player.attack_light_damage += value 
		Stat.HEAVY_DAMAGE:
			player.attack_heavy_damage += value
		
		Stat.LIGHT_SIZE_X:
			#NOTE: Scaling is a bit off?
			#Hitbox
			player.light_attack_shape.size.x *= value
			#Visual
			player.light_attack.scale.x *= value
		Stat.LIGHT_SIZE_Y:
			player.light_attack_shape.size.y *= value
			player.light_attack.scale.y *= value
		Stat.HEAVY_SIZE_X:
			player.heavy_attack_shape.size.x *= value
			player.heavy_attack.scale.x *= value
		Stat.HEAVY_SIZE_Y:
			player.heavy_attack_shape.size.y *= value
			player.heavy_attack.scale.y *= value
			
		Stat.LIFESTEAL:
			player.life_steal += value
			
		Stat.DOT_EFFECT:
			if dot_resource: 
				if ItemGlobals.primary:
					player.primary_attack_active_dot = dot_resource
					
				if ItemGlobals.secondary:
					player.secondary_attack_active_dot = dot_resource
					
		Stat.DEBUFF_EFFECT:
			if debuff_resource: 
				if ItemGlobals.primary:
					player.primary_attack_active_debuff = debuff_resource
					
				if ItemGlobals.secondary:
					player.secondary_attack_active_debuff = debuff_resource
					
		Stat.DASH_COOLDOWN:
			player.dash_cooldown += value
		Stat.DASH_LENGTH:
			player.dash_duration += value
		Stat.DASH_SPEED:
			player.dash_speed += value
		
		Stat.CRIT_CHANCE:
			player.crit_chance += value
		Stat.THORNS_PERCENT:
			player.thorns_percent += value
		
		Stat.LOOT_DROP_CHANCE:
			LootDatabase.update_loot_drop_chance(value)
		Stat.LOOT_RARITY_INC_PERCENT:
			LootDatabase.upgrade_loot_rarity_chance += value
		Stat.PICKUP_LOOT_AMOUNT:
			LootDatabase.pickup_slot_amount += int(value)

func remove_effect(player) -> void:
	match stat_type:
		
		Stat.FLAT_DAMAGE_REDUCTION:
			player.flat_damage_reduction -= value
		Stat.PERCENT_DAMAGE_REDUCTION:
			player.percent_damage_reduction -= value
			
		Stat.HEALTH:
			player.max_health -= value
			if player.health > player.max_health:
				player.health = player.max_health
			player.emit_signal("update_health_bar", player.health, player.max_health)
		Stat.HEALTH_REGEN:
			player.health_regen -= value
		Stat.MOVEMENT_SPEED:
			player.current_speed -= value
			player.movement_speed -= value
			
		Stat.LIGHT_COOLDOWN:
			player.light_attack_speed_scale -= value
		Stat.HEAVY_COOLDOWN:
			player.heavy_attack_cooldown -= value

		Stat.LIGHT_DAMAGE:
			player.attack_light_damage -= value 
		Stat.HEAVY_DAMAGE:
			player.attack_heavy_damage -= value
		
		Stat.LIGHT_SIZE_X:
			player.light_attack_shape.size.x /= value
			player.light_attack.scale.x /= value
		Stat.LIGHT_SIZE_Y:
			player.light_attack_shape.size.y /= value
			player.light_attack.scale.y /= value
		Stat.HEAVY_SIZE_X:
			player.heavy_attack_shape.size.x /= value
			player.heavy_attack.scale.x /= value
		Stat.HEAVY_SIZE_Y:
			player.heavy_attack_shape.size.y /= value
			player.heavy_attack.scale.y /= value
			
		Stat.LIFESTEAL:
			player.life_steal -= value
		Stat.DOT_EFFECT:
			if dot_resource: 
				if ItemGlobals.primary:
					player.primary_attack_active_dot = null
										
				if ItemGlobals.secondary:
					player.secondary_attack_active_dot = null
					
		Stat.DEBUFF_EFFECT:
			if debuff_resource: 
				if ItemGlobals.primary:
					player.primary_attack_active_debuff = null

				if ItemGlobals.secondary:
					player.secondary_attack_active_debuff = null
					
		Stat.DASH_COOLDOWN:
			player.dash_cooldown -= value
		Stat.DASH_LENGTH:
			player.dash_duration -= value
		Stat.DASH_SPEED:
			player.dash_speed -= value
		
		Stat.CRIT_CHANCE:
			player.crit_chance -= value
		Stat.THORNS_PERCENT:
			player.thorns_percent -= value
		
		Stat.LOOT_DROP_CHANCE:
			LootDatabase.update_loot_drop_chance(-value)
		Stat.LOOT_RARITY_INC_PERCENT:
			LootDatabase.upgrade_loot_rarity_chance -= value
		Stat.PICKUP_LOOT_AMOUNT:
			LootDatabase.pickup_slot_amount -= int(value)
