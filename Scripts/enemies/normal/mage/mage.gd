extends EnemyController
class_name Mage

const TP = "teleport"
const TP_ATTACK = "teleport_attack"
const TP_ATTACK_RECOVERY = "teleport_attack_recovery"

@export var aoe_attack: PackedScene = null

@onready var tp_attack_area = $TeleportAttackArea
@onready var tp_attack_hitbox = $TeleportAttackArea/AttackAreaHitbox
@onready var particles = $model/rig/Skeleton3D/BoneAttachment3D/Mesh/Particles

@export var tp_attack_windup_duration := 0.8
@export var tp_attack_duration := 0.8
@export var max_tp_dist := 5
@export var tp_chance := 0.4
@export var tp_max_cooldown := 2.5
var tp_cooldown := 0.0

var tp_target = Vector3.ZERO

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	tp_cooldown -= delta
	
	if tp_cooldown < 0 and state == NAVIGATE:
		tp_cooldown = tp_max_cooldown
		
		if randf() < tp_chance:
			change_state(IDLE)
			return
	
	match state:
		ATTACK:
			face_towards_player(delta)
		
		TP:
			GameManager.particles.emit_particles("teleport", global_position)
			process_tp()
		
		TP_ATTACK:
			process_tp_attack()
		
		TP_ATTACK_RECOVERY:
			process_tp_attack_recovery()


func change_state(new_state: String, duration := 0.0):
	super.change_state(new_state, duration)
	
	match state:
		ATTACK:
			particles.emitting = true
			animator.play("Attack")
			perform_attack(attack, player.global_position)
		IDLE:
			particles.emitting = false
			animator.play("Idle")
			nav_agent.target_desired_distance = attack_range
		NAVIGATE:
			animator.play("Walk")
		TP:
			animator.play("Teleport")
			target_provider = TargetSelf.new()
		TP_ATTACK:
			animator.play("Teleport_attack")
			target_provider = TargetSelf.new()
		COOLDOWN:
			particles.emitting = false
			animator.play("Idle")
		STUN:
			particles.emitting = false
			animator.play("Stun")

func process_attack() -> void:
	if state_timer > 0:
		return
	
	change_state(COOLDOWN, cooldown_duration)

func process_idle() -> void:
	if randf() < tp_chance:
		change_state(TP, 0.4)
		return
	
	change_state(NAVIGATE)

func process_navigation(delta: float) -> void:
	super.process_navigation(delta)
	
	var dist = global_position.distance_to(player.global_position)
	if dist <= attack_range:
		change_state(ATTACK, attack_windup_duration)

func process_tp() -> void:
	if state_timer > 0:
		return
	
	tp_target = pick_tp_pos()
	global_position = tp_target
	
	GameManager.particles.emit_particles("teleport", global_position)
	change_state(TP_ATTACK, tp_attack_windup_duration)

func process_tp_attack() -> void:
	if state_timer > 0:
		return
	
	perform_attack(aoe_attack)
	change_state(TP_ATTACK_RECOVERY, tp_attack_duration-tp_attack_windup_duration)

func process_tp_attack_recovery() -> void:
	if state_timer > 0:
		return
	
	change_state(COOLDOWN, cooldown_duration)

func face_towards_player(delta: float) -> void:
	var dir = (player.global_position - global_transform.origin).normalized()
	update_facing_dir(delta, dir)

func pick_tp_pos() -> Vector3:
	var dir = (player.global_position - global_position).normalized()
	
	var dist = global_position.distance_to(player.global_position)
	var tp_pos = Vector3.ZERO
	
	if dist < max_tp_dist:
		tp_pos = global_position + dir * (dist + attack_range)
	else:
		tp_pos = global_position + dir * max_tp_dist
	
	return Vector3(tp_pos.x, global_position.y, tp_pos.z)
