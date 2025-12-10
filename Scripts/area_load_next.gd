extends Node3D
var unlocked:bool =true



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		# add prompt?
		if unlocked==true:
			#Maybe signal a key to press not just this?
			GameManager.load_next_stage()
		else:
			pass # Play sound or something?
		

func _on_area_3d_body_exited(body: Node3D) -> void:
	pass # Replace with function body.
