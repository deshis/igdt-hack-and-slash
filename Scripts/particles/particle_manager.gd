extends Node3D
class_name ParticleManager

@export var particles : Array[PackedScene]

func emit_particles(n: String, pos: Vector3, parent: Node = null):
	for scene in particles:
		if n == scene.resource_path.get_file().get_basename():
			var particle = scene.instantiate()
			if parent:
				parent.add_child(particle)
			else:
				add_child(particle)
				
			particle.global_position = pos
