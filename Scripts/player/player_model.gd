extends Node3D

@onready var rig = $rig
@onready var anim = $AnimationPlayer

var moving = false

func rotate_model(direction):
	if direction.length() > 0:
		rig.rotation.y = atan2(-direction.y, direction.x) + PI/2
		if !moving:
			anim.play("Run")
			moving = true
	
	elif moving:
		anim.play("Idle")
		moving = false
