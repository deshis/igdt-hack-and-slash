extends EnemyController	
class_name Mage

@export var tp_max_dist := 500
@export var wait_before_tp_timer: Timer
var is_teleporting := false
var tp_pos = Vector2.ZERO

var attack_dist := 200.0
var attack_dist_min := 150.0
var attack_dist_max := 250.0

@export var face_player_length_timer: Timer
var face_player = false

func _physics_process(delta: float) -> void:
	if not player or not target_provider:
		return
	
	if not is_teleporting:
		start_teleport()
	
	if face_player:
		face_towards_player(delta)

func face_towards_player(delta: float) -> void:
	var dir = (player.global_position - global_transform.origin).normalized()
	update_facing_dir(delta, dir)

func start_teleport() -> void:
	is_teleporting = true
	
	attack_dist = randf_range(attack_dist_min, attack_dist_max)
	
	var dist = global_position.distance_to(player.global_position)
	
	if dist < attack_dist:
		face_player = true
		face_player_length_timer.start()
	else:
		wait_before_tp_timer.start()

func _on_face_player_length_timer_timeout() -> void:
	face_player = false
	wait_before_attack_timer.start()

func _on_wait_before_teleport_timer_timeout() -> void:
	if not player:
		return
	
	var dist = global_position.distance_to(player.global_position)
	var dir = (GameManager.player.global_position - global_position).normalized()
	
	if dist > tp_max_dist:
		tp_pos = global_position + dir * tp_max_dist
		wait_after_attack_timer.start()
	else:
		tp_pos = global_position + dir * (dist + attack_dist)
		face_player = true
		face_player_length_timer.start()
	
	global_position = tp_pos

func _on_wait_after_attack_timer_timeout() -> void:
	is_teleporting = false
	
