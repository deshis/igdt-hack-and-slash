extends Attack

var attack_mat : ShaderMaterial

func _ready() -> void:
	super._ready()
	
	attack_mat = $Circle.material_override.duplicate()
	$Circle.material_override = attack_mat

func _process(_delta: float) -> void:
	super._process(_delta)
	
	attack_mat.set_shader_parameter("life_time", (duration-timer.time_left) / duration)
