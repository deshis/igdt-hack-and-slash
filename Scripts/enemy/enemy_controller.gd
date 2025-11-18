extends CharacterBody2D
class_name EnemyController

@export var pickupable_item: PackedScene

@export var enemy: EnemyStats
var target_provider: TargetProvider

@export var nav_agent: NavigationAgent2D

@export var attack_area: Area2D
@export var attack_area_hitbox: CollisionShape2D

@export var wait_before_attack_timer: Timer
@export var attack_length_timer: Timer
@export var wait_after_attack_timer: Timer

var player: Node2D
var target: Node2D
var is_navigating := true
var target_reached := false

@onready var current_speed := enemy.speed

func _ready() -> void:
	attack_area_hitbox.disabled = true

func _physics_process(delta: float) -> void:
	if not player or not target_provider:
		return
	
	if is_navigating:
		process_navigation(delta)


func process_navigation(delta: float) -> void:
	var new_target_pos = target_provider.get_target(self, player)
	
	if global_position.distance_to(new_target_pos) > 1.0:
		nav_agent.set_target_position(new_target_pos)
	
	if nav_agent.is_navigation_finished():
		return
	
	var next_pos = nav_agent.get_next_path_position()
	var dir = (next_pos - global_transform.origin).normalized()
	
	update_facing_dir(delta, dir)
	apply_movement(delta, dir)

func apply_movement(delta: float, dir: Vector2) -> void:
	velocity = lerp(velocity, dir * current_speed, enemy.acceleration * delta)
	move_and_slide()

func update_facing_dir(delta: float, dir: Vector2) -> void:
	var target_angle = dir.angle() + Vector2.DOWN.angle()
	rotation = lerp_angle(rotation, target_angle, enemy.rotation_speed * delta)

func perform_attack() -> void:
	if not attack_length_timer:
		_on_wait_after_attack_timer_timeout()
		return
	
	attack_area.visible = true
	attack_area_hitbox.disabled = false
	
	attack_length_timer.start()

func take_damage(damage:float) -> void:
	enemy.health -= damage
	
	SoundManager.play_sfx("hit", global_position)
	
	if enemy.health <= 0.0:
		die()

func die() -> void:
	SoundManager.play_sfx("enemy_die", global_position)
	# TODO: proper item drop system, just a quick mockup
	if randi_range(1,5) == 1:
		var item = pickupable_item.instantiate()
		get_parent().add_child(item)
		item.global_position = global_position
	queue_free()


func _on_attack_area_area_entered(_area: Area2D) -> void:
	player.take_damage(enemy.damage)

func _on_navigation_agent_2d_target_reached() -> void:
	if not wait_before_attack_timer:
		perform_attack()
		return
	
	target_provider = TargetSelf.new()
	wait_before_attack_timer.start()

func _on_wait_before_attack_timer_timeout() -> void:
	perform_attack()

func _on_attack_length_timer_timeout() -> void:
	if not wait_after_attack_timer:
		_on_wait_after_attack_timer_timeout()
		return
	
	attack_area.visible = false
	attack_area_hitbox.disabled = true
	
	wait_after_attack_timer.start()

func _on_wait_after_attack_timer_timeout() -> void:
	target_provider = TargetPlayer.new()
