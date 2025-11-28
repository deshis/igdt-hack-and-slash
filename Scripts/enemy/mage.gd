extends EnemyController	
class_name Mage

enum State {
	IDLE,
	NAVIGATE,
	NORMAL_ATTACK,
	TP_PREP,
	TP_MOVE,
	TP_ATTACK,
	COOLDOWN
}

var state = State.IDLE
var state_timer := 0.0
var teleport_chance := 0.2



@export var teleport_attack_damage := 4.0
@export var tp_max_dist := 500.0
@export var tp_cooldown := 2.0
@export var wait_before_tp_timer: Timer
@export var tp_cooldown_timer: Timer
var can_teleport := true
var is_teleporting := false
var tp_pos = Vector2.ZERO

@export var tp_attack_area: Area2D
@export var tp_attack_hitbox: CollisionShape2D

var normal_attack_damage = 0.0
var attack_dist := 200.0
var attack_dist_min := 150.0
var attack_dist_max := 250.0

@export var face_player_length_timer: Timer
var face_player = false

func _ready() -> void:
	super._ready()
	tp_attack_area.visible = false
	tp_attack_hitbox.disabled = true
	normal_attack_damage = enemy.damage
	
	"change_state(State.IDLE)"

"func change_state(new_state: State, duration := 0.0):
	state = new_state
	state_timer = duration
	
	match state:
		State.IDLE: target_provider = TargetPlayer.new()
		State.NAVIGATE: target_provider = TargetPlayer.new()
		State.NORMAL_ATTACK: enemy.damage = normal_attack_damage
		State.TP_PREP: target_provider = TargetSelf.new()
		State.TP_MOVE: enemy.damage = teleport_attack_damage"

func _physics_process(delta: float) -> void:
	if not player or not target_provider:
		return
	
	if can_teleport:
		start_teleport()
	
	if not is_teleporting:
		process_navigation(delta)
	
	if face_player:
		face_towards_player(delta)

func face_towards_player(delta: float) -> void:
	var dir = (player.global_position - global_transform.origin).normalized()
	update_facing_dir(delta, dir)

func start_teleport() -> void:
	can_teleport = false
	is_teleporting = true
	target_provider = TargetSelf.new()
	
	attack_dist = randf_range(attack_dist_min, attack_dist_max)
	var dist = global_position.distance_to(player.global_position)
	
	if dist < attack_dist:
		face_player = true
		face_player_length_timer.start()
	else:
		wait_before_tp_timer.start()

func perform_teleport_attack() -> void:
	tp_attack_area.visible = true
	tp_attack_hitbox.disabled = false
	
	attack_length_timer.start()


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
	tp_cooldown_timer.start()

func _on_wait_before_attack_timer_timeout() -> void:
	if is_teleporting:
		enemy.damage = teleport_attack_damage
		perform_teleport_attack()
	else:
		enemy.damage = normal_attack_damage
		perform_attack()

func _on_wait_after_attack_timer_timeout() -> void:
	is_teleporting = false
	target_provider = TargetPlayer.new()

func _on_teleport_cooldown_timer_timeout() -> void:
	can_teleport = true

func _on_attack_length_timer_timeout() -> void:
	super._on_attack_length_timer_timeout()
	tp_attack_area.visible = false
	tp_attack_hitbox.disabled = true

func _on_teleport_attack_area_area_entered(area: Area2D) -> void:
	super._on_attack_area_area_entered(area)
