extends Attack

@export var arc_radius_min := 150.0
@export var arc_radius_max := 300.0
@export var arc_angle_min := 270.0
@export var arc_angle_max := 360.0

var previous_pos = null
var speed := 0.0

var center
var radius
var angle_start
var angle_end
var time = 0.0

var enemy

const ARC = "arc"
const RETURN = "return"
var state = ARC

func _ready() -> void:
	enemy = get_parent()
	
	var enemy_pos = enemy.global_position
	var enemy_rot = enemy.global_rotation
	radius = randf_range(arc_radius_min, arc_radius_max)
	
	var center_offset = Vector2.UP.rotated(enemy_rot) * radius
	center = enemy_pos + center_offset
	
	angle_start = (enemy_pos - center).angle()
	angle_end = deg_to_rad(randf_range(arc_angle_min, arc_angle_max))
	
	super._ready()

func _physics_process(delta: float) -> void:
	match state:
		ARC:
			process_arc()
		
		RETURN:
			process_return(delta)
	
	time += delta
	
	if previous_pos:
		speed = previous_pos.distance_to(global_position) / delta
	previous_pos = global_position

func process_arc() -> void:
	if time < hitbox_duration:
		var t = time / hitbox_duration
		var angle = lerp(angle_start, angle_start + angle_end, t)
		
		global_position = center + Vector2(
			cos(angle) * radius,
			sin(angle) * radius
		)

func process_return(delta: float) -> void:
	var enemy_pos = enemy.global_position
	
	var dir = (enemy_pos - global_position).normalized()
	global_position += dir * speed * delta
	
	if global_position.distance_to(enemy_pos) < 10.0:
		remove_attack()

func start_attack() -> void:
	for body in area.get_overlapping_areas():
		_on_area_2d_area_entered(body)
	
	# boomerang duration
	await get_tree().create_timer(hitbox_duration).timeout
	state = RETURN
