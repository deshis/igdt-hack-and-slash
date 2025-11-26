extends EnemyController
class_name Claw

@export var face_player_length_timer: Timer
var face_player = false

@export var wait_before_spin_attack_timer: Timer
@export var spin_attack_area: Area2D
@export var spin_attack_hitbox: CollisionShape2D

@export var spin_attack_length := 1.2
@export var spin_speed := 10.0
var is_attacking := false
var is_spin_attacking := false
var is_spinning := false
var spin_target := Vector2.ZERO

func _ready() -> void:
	super._ready()
	spin_attack_hitbox.disabled = true

func _physics_process(delta: float) -> void:
	if not player or not target_provider:
		return
		
	process_navigation(delta)
	
	if face_player:
		face_towards_player(delta)
	elif is_spinning:
		perform_spin(delta)


func start_claw_attack() -> void:
		face_player = true
		face_player_length_timer.start()

func start_spin_attack() -> void:
	is_spinning = true
	wait_before_spin_attack_timer.start()

func perform_attack() -> void:
	attack_area.visible = true
	attack_area_hitbox.disabled = false
	
	attack_length_timer.start()

func perform_spin_attack() -> void:
	spin_attack_area.visible = true
	spin_attack_hitbox.disabled = false
	is_spin_attacking = true
	current_speed = global_position.distance_to(spin_target) / spin_attack_length
	
	attack_length_timer.start(spin_attack_length)

func perform_spin(delta: float) -> void:
	rotation += delta * spin_speed

func face_towards_player(delta: float) -> void:
	var dir = (player.global_position - global_transform.origin).normalized()
	update_facing_dir(delta, dir)

func process_navigation(delta: float) -> void:
	var new_target_pos := Vector2.ZERO
	
	if is_spin_attacking:
		new_target_pos = spin_target
	else:
		new_target_pos = target_provider.get_target(self, player)
	
	var dir = Vector2.ZERO
	
	if not is_spin_attacking:
		if global_position.distance_to(new_target_pos) > 1.0:
			nav_agent.set_target_position(new_target_pos)
	
		if nav_agent.is_navigation_finished():
			return
	
		var next_pos = nav_agent.get_next_path_position()
		dir = (next_pos - global_transform.origin).normalized()
		
		if not is_spinning:
			update_facing_dir(delta, dir)
	else:
		dir = (new_target_pos - global_transform.origin).normalized()
	
	apply_movement(delta, dir)


func _on_navigation_agent_2d_target_reached() -> void:
	if not is_navigating:
		return
	
	is_navigating = false
	var rng = randi_range(0, 1)
	
	if rng == 0:
		target_provider = TargetSelf.new()
		start_claw_attack()
	else:
		target_provider = TargetPastPlayer.new()
		start_spin_attack()

func _on_face_player_length_timer_timeout() -> void:
	face_player = false
	wait_before_attack_timer.start()

func _on_attack_length_timer_timeout() -> void:
	super._on_attack_length_timer_timeout()
	
	spin_attack_area.visible = false
	spin_attack_hitbox.disabled = true
	is_spin_attacking = false
	is_spinning = false
	current_speed = enemy.speed
	spin_target = Vector2.ZERO

func _on_wait_before_spin_attack_timer_timeout() -> void:
	spin_target = target_provider.get_target(self, player)
	target_provider = TargetSelf.new()
	perform_spin_attack()
