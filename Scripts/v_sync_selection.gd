extends OptionButton

@onready var vp_rid = get_viewport().get_viewport_rid()

func _ready() -> void:
	match DisplayServer.window_get_vsync_mode():
		DisplayServer.VSyncMode.VSYNC_DISABLED:
			selected = 0
		DisplayServer.VSyncMode.VSYNC_ENABLED:
			selected = 1

func _on_item_selected(index: int) -> void:
	match index:
		0: 
			DisplayServer.window_set_vsync_mode(DisplayServer.VSyncMode.VSYNC_DISABLED)
		1:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSyncMode.VSYNC_ENABLED)
