extends EnemyController
class_name Microbot

@export var target_dist_min := 100.0
@export var target_dist_max := 250.0

@onready var trail = $"model/BlastWave"

func _ready():
	super._ready()
	var mesh_instance = $"model/Rig/Skeleton3D/Microbot"
	var base_mat = mesh_instance.mesh.surface_get_material(0)
	var unique_mat = base_mat.duplicate()
	var next_pass_base = hit_flash_material
	var next_pass_unique = next_pass_base.duplicate()
	unique_mat.next_pass = next_pass_unique
	mesh_instance.set_surface_override_material(0, unique_mat)
	hit_flash = next_pass_unique

func change_state(new_state: String, duration := 0.0):
	super.change_state(new_state, duration)
	
	match state:
		IDLE:
			trail.visible = false
			animator.play("Idle")
			nav_agent.target_desired_distance = randf_range(target_dist_min, target_dist_max)
		NAVIGATE:
			trail.visible = false
			animator.play("Walk")
			current_speed = enemy.speed
		STUN:
			trail.visible = false
			animator.play("Stun")
		ATTACK:
			animator.play("Attack")
