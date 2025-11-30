extends EnemyController	
class_name Slasher

@export var face_player_duration := 0.667
@export var dash_speed := 1000.0
@export var dash_duration := 0.3

const FACE_PLAYER = "face_player"
const DASH = "dash"

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	match state:
		FACE_PLAYER:
			process_face_player(delta)
		
		DASH:
			process_dash(delta)


func change_state(new_state: String, duration := 0.0):
	super.change_state(new_state, duration)
	
	match state:
		NAVIGATE:
			animator.play("Walk")
			current_speed = enemy.speed
		
		FACE_PLAYER:
			animator.play("Attack")
			target_provider = TargetSelf.new()
		
		DASH:
			current_speed = dash_speed


func process_face_player(delta: float) -> void:
	var dir = (player.global_position - global_transform.origin).normalized()
	update_facing_dir(delta, dir)
	
	if state_timer < 0:
		change_state(ATTACK, attack_windup_duration)

func process_attack() -> void:
	perform_attack(attack)
	change_state(DASH, dash_duration)

func process_dash(delta: float) -> void:
	var dash_dir = Vector2.UP.rotated(rotation)
	apply_movement(delta, dash_dir)
	
	if state_timer < 0:
		change_state(COOLDOWN, cooldown_duration)


func _on_navigation_agent_2d_target_reached() -> void:
	change_state(FACE_PLAYER, face_player_duration)
