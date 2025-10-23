extends Node

var cfg = ConfigFile.new()

const CFG_PATH = ("user://preferences.cfg")

enum AntiAliasing {
	OFF,
	TAA,
	MSAA2X,
	MSAA4X,
	MSAA8X,
}

func _ready() -> void:
	if FileAccess.file_exists(CFG_PATH):
		cfg.load(CFG_PATH)
	else:
		cfg.set_value("keybinds", "move_up", "W")
		cfg.set_value("keybinds", "move_left", "A")
		cfg.set_value("keybinds", "move_down", "S")
		cfg.set_value("keybinds", "move_right", "D")
		cfg.set_value("keybinds", "movement_ability", "Shift")
		cfg.set_value("keybinds", "inventory", "Tab")
		
		cfg.set_value("video", "antialiasing", AntiAliasing.TAA)
		cfg.set_value("video", "vsync", true)
		cfg.set_value("video", "fullscreen", false)
		
		cfg.set_value ("audio", "master_volume", 1.0)
		cfg.set_value ("audio", "music_volume", 1.0)
		cfg.set_value ("audio", "sfx_volume", 1.0)
		
		cfg.save(CFG_PATH)


func save_video_setting(key:String, val)->void:
	cfg.set_value("video", key, val)
	cfg.save(CFG_PATH)


func load_video_settings() -> Dictionary:
	var video_settings:= {}
	for key in cfg.get_section_keys("video"):
		video_settings[key] = cfg.get_value("video", key)
	return video_settings


func save_audio_setting(key:String, val)->void:
	cfg.set_value("audio", key, val)
	cfg.save(CFG_PATH)


func load_audio_settings() -> Dictionary:
	var audio_settings:= {}
	for key in cfg.get_section_keys("audio"):
		audio_settings[key] = cfg.get_value("audio", key)
	return audio_settings


func save_keybind(action:StringName, event:InputEvent)->void:
	var event_str = OS.get_keycode_string(event.physical_keycode)
	cfg.set_value("keybinds", action, event_str)
	cfg.save(CFG_PATH)


func load_keybinds() -> Dictionary:
	var keybinds:= {}
	var keys = cfg.get_section_keys("keybinds")
	for key in keys:
		var event_str = cfg.get_value("keybinds", key)
		var input_event = InputEventKey.new()
		input_event.keycode = OS.find_keycode_from_string(event_str)
		keybinds[key] = input_event
	return keybinds
