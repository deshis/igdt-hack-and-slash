extends CheckButton


func _ready() -> void:
	var video_settings = CfgHandler.load_video_settings()
	button_pressed = video_settings.vsync
	if video_settings.vsync:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		CfgHandler.save_video_setting("vsync", true)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		CfgHandler.save_video_setting("vsync", false)
