extends Node3D

@onready var cam = $CameraPoint
@onready var anim = $AnimationPlayer

func rotate_cam(direction):
	if direction.length() > 0:
		cam.rotation.y = atan2(-direction.x, direction.y)

func set_cam_rotation(rot):
	cam.rotation.y = rot + PI
