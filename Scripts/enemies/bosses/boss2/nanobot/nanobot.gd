extends Microbot
class_name Nanobot

func _ready() -> void:
	super._ready()
	change_state(COOLDOWN, cooldown_duration)

func die() -> void:
	SoundManager.play_sfx("enemy_die", global_position)
	
	#Death particles here
	#TODO: clean these
	if death_particles:
		death_particles.get_parent().remove_child(death_particles)
		get_tree().get_root().add_child(death_particles)
		death_particles.global_position = global_position
		death_particles.restart()
		death_particles2.restart()
		
	if health_bar:
		health_bar.queue_free()
	
	GameStats.enemies_killed +=1
	queue_free()


func _on_attack_area_area_entered(_area: Area2D, damage: float = enemy.damage) -> void:
	GameStats.player_last_hit_by = enemy.name
	player.take_damage(damage, true)
