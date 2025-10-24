extends HSlider

@export var bus_name:String

var bus_index:int

func _ready() -> void:
	
	var audio_settings = CfgHandler.load_audio_settings()
	match bus_name:
		"Master":
			value = audio_settings.master_volume
		"Music":
			value = audio_settings.music_volume
		"SFX":
			value = audio_settings.sfx_volume
	
	bus_index = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	value_changed.connect(_on_value_changed)



func _on_value_changed(val:float)->void:
	match bus_name:
		"Master":
			CfgHandler.save_audio_setting("master_volume", val)
		"Music":
			CfgHandler.save_audio_setting("music_volume", val)
		"SFX":
			CfgHandler.save_audio_setting("sfx_volume", val)
	
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(val))
	
