extends EnemyController	
class_name Boss
var speed=10
@export var face_player_length_timer: Timer
var face_player = false

@export var dash_speed = 1000
var is_dashing = false

func _physics_process(delta: float) -> void:
	if not player or not target_provider:
		return
	
	if is_dashing:
		var dash_dir = Vector2.UP.rotated(rotation)
		apply_movement(delta, dash_dir)
	else:
		process_navigation(delta)
	
	if face_player:
		face_towards_player(delta)


func perform_attack() -> void:
	attack_area.visible = true
	attack_area_hitbox.disabled = false
	is_dashing = true
	current_speed = dash_speed
	
	attack_length_timer.start()

func face_towards_player(delta: float) -> void:
	var dir = (player.global_position - global_transform.origin).normalized()
	update_facing_dir(delta, dir)


func _on_navigation_agent_2d_target_reached() -> void:
	target_provider = TargetSelf.new()
	face_player = true
	face_player_length_timer.start()


func _on_face_player_length_timer_timeout() -> void:
	face_player = false
	wait_before_attack_timer.start()

func _on_wait_before_attack_timer_timeout() -> void:
	perform_attack()

func _on_attack_length_timer_timeout() -> void:
	attack_area.visible = false
	attack_area_hitbox.disabled = true

	is_dashing = false
	current_speed = enemy.speed
	
	wait_after_attack_timer.start()

func _on_wait_after_attack_timer_timeout() -> void:
	target_provider = TargetPlayer.new()
