extends CheckButton

func _ready() -> void:
	var video_settings = CfgHandler.load_video_settings()
	button_pressed = video_settings.fullscreen
	if video_settings.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		CfgHandler.save_video_setting("fullscreen", true)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		CfgHandler.save_video_setting("fullscreen", false)
