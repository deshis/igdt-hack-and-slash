extends EnemyController
class_name Mage

const FACE_PLAYER = "face_player"
const TP = "teleport"
const TP_ATTACK = "teleport_attack"

@export var aoe_attack: PackedScene = null

@onready var tp_attack_area = $TeleportAttackArea
@onready var tp_attack_hitbox = $TeleportAttackArea/AttackAreaHitbox

@export var attack_duration := 0.2
@export var face_time := 0.6

@export var max_tp_dist := 500
@export var tp_chance := 0.4

var tp_target = Vector2.ZERO
var normal_attack_damage = 0.0

func _ready() -> void:
	super._ready()
	normal_attack_damage = enemy.damage
	
	change_state(IDLE)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	match state:
		FACE_PLAYER:
			process_face_player(delta)
		
		TP:
			process_tp()
		
		TP_ATTACK:
			process_tp_attack()


func change_state(new_state: String, duration := 0.0):
	super.change_state(new_state, duration)
	
	match state:
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
		change_state(FACE_PLAYER, face_time)

func process_face_player(delta: float) -> void:
	if state_timer > 0:
		face_towards_player(delta)
		return
	
	change_state(ATTACK, attack_duration)

func process_tp() -> void:
	if state_timer > 0:
		return
	
	tp_target = pick_tp_pos()
	global_position = tp_target
	
	change_state(TP_ATTACK, attack_duration)

func process_tp_attack() -> void:
	if state_timer > 0:
		return
	
	perform_attack(aoe_attack)
	change_state(COOLDOWN, cooldown_duration)


func pick_tp_pos() -> Vector2:
	var dir = (player.global_position - global_position).normalized()
	
	var dist = global_position.distance_to(player.global_position)
	var tp_pos = Vector2.ZERO
	
	if dist < max_tp_dist:
		tp_pos = global_position + dir * (dist + attack_range)
	else:
		tp_pos = global_position + dir * max_tp_dist
	
	return tp_pos

func face_towards_player(delta: float) -> void:
	var dir = (player.global_position - global_transform.origin).normalized()
	update_facing_dir(delta, dir)
