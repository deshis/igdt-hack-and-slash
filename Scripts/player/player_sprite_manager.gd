extends Sprite2D

@onready var model = $"../SubViewport/model"
@onready var afterimage_particles = $AfterimageParticles

#Storing the light attack speed scale in player.gd so I can access it with my item code
@onready var player_script = get_parent()

enum STATE {IDLE, RUN, LIGHT_ATTACK}

var current_state = STATE.IDLE

signal light_attack_finished
signal heavy_attack_finished


func _ready():
	var a =  $"../SubViewport/model/AnimationPlayer"
	a.animation_finished.connect(_on_anim_finished)

func _process(_delta):
	rotation = -get_parent().global_rotation

func update_sprite(direction):
	if current_state == STATE.LIGHT_ATTACK: return
	model.rotate_cam(direction)
	if direction.length() > 0 and current_state != STATE.RUN:
		model.anim.play("Run")
		current_state = STATE.RUN
	elif direction.length() == 0 and current_state != STATE.IDLE:
		model.anim.play("Idle")
		current_state = STATE.IDLE

func start_dash():
	afterimage_particles.emitting = true
	model.anim.play("Dash")

func stop_dash():
	afterimage_particles.emitting = false
	if current_state == STATE.RUN: 
		model.anim.play("Run")
	else: 
		model.anim.play("Idle")

func light_attack(rot):
	current_state = STATE.LIGHT_ATTACK
	model.set_cam_rotation(rot)
	#Separating the speed scale to modify it in isolation
	model.anim.speed_scale = player_script.light_attack_speed_scale
	model.anim.play("Dagger")

func _on_anim_finished(anim_name):
	current_state = STATE.IDLE
	model.anim.speed_scale = 1
	model.anim.play("Idle")
	match  anim_name:
		"Dagger":
			light_attack_finished.emit()
