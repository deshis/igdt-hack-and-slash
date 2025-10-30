extends Resource
class_name StatsResource

#@export var stat_type: Stat = Stat.HEALTH

@export var stat_type: Stat = Stat.HEALTH
@export var value: float = 0.0

enum Stat { 
	HEALTH, 
	SPEED, 
	LIGHTDAMAGE,
	HEAVYDAMAGE
	}

func apply_effect(player) -> void:
	match stat_type:
		Stat.HEALTH:
			player.health += value
			player.max_health += value
		Stat.SPEED:
			player.current_speed += value
			player.movement_speed += value
		Stat.LIGHTDAMAGE:
			player.attack_light_damage += value
		Stat.HEAVYDAMAGE:
			player.attack_heavy_damage += value

func remove_effect(player) -> void:
	match stat_type:
		Stat.HEALTH:
			player.health -= value
			player.max_health -= value
		Stat.SPEED:
			player.current_speed -= value
			player.movement_speed -= value
		Stat.LIGHTDAMAGE:
			player.attack_light_damage -= value
		Stat.HEAVYDAMAGE:
			player.attack_heavy_damage -= value
