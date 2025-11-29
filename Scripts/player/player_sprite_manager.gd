extends Sprite2D

@onready var model = $"../SubViewport/model"
@onready var afterimage_particles = $AfterimageParticles
@onready var weapon_mesh = $"../SubViewport/model/rig/Skeleton3D/BoneAttachment3D/Weapon/Mesh"

#Storing the light attack speed scale in player.gd so I can access it with my item code
@onready var player_script = get_parent()

enum STATE {IDLE, RUN, LIGHT_ATTACK, DASH}

var current_state = STATE.IDLE

signal light_attack_finished
signal heavy_attack_finished

func _ready():
	var a =  $"../SubViewport/model/AnimationPlayer"
	a.animation_finished.connect(_on_anim_finished)
	#var og_dash_cooldown = player_script.dash_cooldown

func _process(_delta):
	rotation = -get_parent().global_rotation

func update_sprite(direction):
	
	if current_state == STATE.LIGHT_ATTACK: return
		
	model.rotate_cam(direction)
	if direction.length() > 0 and current_state != STATE.RUN:
		model.anim.speed_scale = player_script.movement_speed / player_script.default_speed
		model.anim.play("Run")
		current_state = STATE.RUN
	elif direction.length() == 0 and current_state != STATE.IDLE:
		model.anim.speed_scale = 1
		model.anim.play("Idle")
		current_state = STATE.IDLE

func start_dash():
	
	#if current_state == STATE.LIGHT_ATTACK:
		#current_state = STATE.DASH
		#player_script.dash_cooldown *= 2
		
	current_state = STATE.DASH
	light_attack_finished.emit() #Dash cancels attack animation
	afterimage_particles.emitting = true
	model.anim.play("Dash")

func stop_dash():
	afterimage_particles.emitting = false
	if current_state == STATE.RUN: 
		model.anim.play("Run")
	else: 
		model.anim.play("Idle")

func light_attack(rot):
	
	var model_anim := "?"
	
	#print("Primary attack: ",ItemGlobals.primary_attack_type," || Primary weapon type: ",ItemGlobals.primary_weapon_type)
	#print("Secondary attack: ",ItemGlobals.secondary_attack_type," || Secondary weapon type: ",ItemGlobals.secondary_weapon_type)
	
	current_state = STATE.LIGHT_ATTACK
	model.set_cam_rotation(rot)
	#Separating the speed scale to modify it in isolation
	model.anim.speed_scale = player_script.light_attack_speed_scale
	weapon_mesh.mesh = ItemGlobals.primary_weapon_mesh
	
	if ItemGlobals.primary_weapon_type == "Dagger":
		model_anim = "Light_attack_dagger"
		model.anim.play(model_anim)
		return

	if ItemGlobals.primary_weapon_type == "Sword":
		model_anim = "Light_attack_sword"
		model.anim.play(model_anim)
		return
		
	else:
		model_anim = "Light_attack_default"
		model.anim.play(model_anim)
		return
		
	
func _on_anim_finished(anim_name):
	#if current_state == STATE.DASH:
		#return
	current_state = STATE.IDLE
	model.anim.speed_scale = 1
	model.anim.play("Idle")
	if anim_name.begins_with("Light_attack_"):
		weapon_mesh.mesh = null
		light_attack_finished.emit()
