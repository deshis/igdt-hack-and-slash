extends CPUParticles2D

#TODO: MAKE IT WORK

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

#called once the particle has finished playing
func _on_finished() -> void:
	queue_free()
