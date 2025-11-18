extends Resource
class_name Stats 

@export var stat_type: Stat = Stat.HEALTH
@export var value: float = 0.0

signal update_health_bar

enum Stat { 
	HEALTH, 
	MOVEMENT_SPEED, 
	LIGHT_DAMAGE,
	HEAVY_DAMAGE,
	LIGHT_COOLDOWN,
	HEAVY_COOLDOWN,
	
	LIGHT_SIZE_X,
	LIGHT_SIZE_Y,
	HEAVY_SIZE_X,
	HEAVY_SIZE_Y
	}
	
func apply_effect(player) -> void:
	match stat_type:
		
		Stat.HEALTH:
			player.health += value
			player.max_health += value
			player.emit_signal("update_health_bar", player.health)
		Stat.MOVEMENT_SPEED:
			player.current_speed += value
			player.movement_speed += value
			
		Stat.LIGHT_COOLDOWN:
			player.light_attack_cooldown += value
		Stat.HEAVY_COOLDOWN:
			player.heavy_attack_cooldown += value

		Stat.LIGHT_DAMAGE:
			player.attack_light_damage += value 
		Stat.HEAVY_DAMAGE:
			player.attack_heavy_damage += value

		Stat.LIGHT_SIZE_X:
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

func remove_effect(player) -> void:
	match stat_type:
		
		Stat.HEALTH:
			player.health -= value
			player.max_health -= value
			player.emit_signal("update_health_bar", player.health)
		Stat.MOVEMENT_SPEED:
			player.current_speed -= value
			player.movement_speed -= value
			
		Stat.LIGHT_COOLDOWN:
			player.light_attack_cooldown -= value
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
