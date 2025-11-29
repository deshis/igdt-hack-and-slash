extends EnemyController	
class_name Slasher

@export var face_player_length_timer: Timer
var face_player = false

@export var dash_speed = 1000
var is_dashing = false

@onready var animator = $"SubViewport/3DView/slasher/AnimationPlayer"
@onready var model_view = $"SubViewport/3DView"
@onready var camera_point = $"SubViewport/3DView/slasher"
@onready var slasher_sprite = $Sprite2D

func _ready() -> void:
	model_view.position = Vector3(randf()*1e6, randf()*1e6, randf()*1e6)
	animator.animation_finished.connect(_on_anim_finished)

func _physics_process(delta: float) -> void:
	slasher_sprite.rotation = -rotation
	camera_point.rotation.y = -deg_to_rad(round(rad_to_deg(rotation+PI) / 5.0) * 5.0)
	
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


func face_towards_player(delta: float) -> void:
	var dir = (player.global_position - global_transform.origin).normalized()
	update_facing_dir(delta, dir)

func _on_navigation_agent_2d_target_reached() -> void:
	target_provider = TargetSelf.new()
	face_player = true
	face_player_length_timer.start()
	animator.play("Attack")

func _on_face_player_length_timer_timeout() -> void:
	face_player = false
	wait_before_attack_timer.start()

func _on_attack_length_timer_timeout() -> void:
	super._on_attack_length_timer_timeout()
	is_dashing = false
	current_speed = enemy.speed
	animator.play("Walk")

func _on_anim_finished(anim_name):
	match anim_name:
		'Attack':
			_on_attack_length_timer_timeout()
