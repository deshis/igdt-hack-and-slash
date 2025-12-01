extends EnemyController
class_name Mage

const TP = "teleport"
const TP_ATTACK = "teleport_attack"

@export var aoe_attack: PackedScene = null

@onready var tp_attack_area = $TeleportAttackArea
@onready var tp_attack_hitbox = $TeleportAttackArea/AttackAreaHitbox

@export var tp_attack_windup_duration := 0.8
@export var max_tp_dist := 500
@export var tp_chance := 0.4
@export var tp_max_cooldown := 2.5
var tp_cooldown := 0.0

var tp_target = Vector2.ZERO

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
			face_towards_player()
		
		TP:
			process_tp()
		
		TP_ATTACK:
			process_tp_attack()


func change_state(new_state: String, duration := 0.0):
	super.change_state(new_state, duration)
	
	match state:
		IDLE:
			nav_agent.target_desired_distance = attack_range
		TP:
			target_provider = TargetSelf.new()

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
	
	change_state(TP_ATTACK, tp_attack_windup_duration)

func process_tp_attack() -> void:
	if state_timer > 0:
		return
	
	perform_attack(aoe_attack)
	change_state(COOLDOWN, cooldown_duration)

func face_towards_player() -> void:
	var dir = (player.global_position - global_transform.origin).normalized()
	rotation = dir.angle() + deg_to_rad(90)

func pick_tp_pos() -> Vector2:
	var dir = (player.global_position - global_position).normalized()
	
	var dist = global_position.distance_to(player.global_position)
	var tp_pos = Vector2.ZERO
	
	if dist < max_tp_dist:
		tp_pos = global_position + dir * (dist + attack_range)
	else:
		tp_pos = global_position + dir * max_tp_dist
	
	return tp_pos
