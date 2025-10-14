extends OptionButton

@onready var vp_rid = get_viewport().get_viewport_rid()

func _ready() -> void:
	var taa := get_viewport().use_taa
	var msaa := get_viewport().msaa_2d
	
	if not taa:
		if msaa == RenderingServer.VIEWPORT_MSAA_DISABLED:
			selected = 0
		elif msaa == RenderingServer.VIEWPORT_MSAA_2X:
			selected = 2
		elif msaa == RenderingServer.VIEWPORT_MSAA_4X:
			selected = 3
		else:
			selected = 4
	else:
		selected = 1



func _on_item_selected(index: int) -> void:
	match index:
		0: 
			RenderingServer.viewport_set_use_taa(vp_rid, false)
			RenderingServer.viewport_set_msaa_2d(vp_rid, RenderingServer.VIEWPORT_MSAA_DISABLED)
			RenderingServer.viewport_set_msaa_3d(vp_rid, RenderingServer.VIEWPORT_MSAA_DISABLED)
		1:
			RenderingServer.viewport_set_use_taa(vp_rid, true)
			RenderingServer.viewport_set_msaa_2d(vp_rid, RenderingServer.VIEWPORT_MSAA_DISABLED)
			RenderingServer.viewport_set_msaa_3d(vp_rid, RenderingServer.VIEWPORT_MSAA_DISABLED)
		2: 
			RenderingServer.viewport_set_use_taa(vp_rid, false)
			RenderingServer.viewport_set_msaa_2d(vp_rid, RenderingServer.VIEWPORT_MSAA_2X)
			RenderingServer.viewport_set_msaa_3d(vp_rid, RenderingServer.VIEWPORT_MSAA_2X)
		3:
			RenderingServer.viewport_set_use_taa(vp_rid, false)
			RenderingServer.viewport_set_msaa_2d(vp_rid, RenderingServer.VIEWPORT_MSAA_4X)
			RenderingServer.viewport_set_msaa_3d(vp_rid, RenderingServer.VIEWPORT_MSAA_4X)
		4:
			RenderingServer.viewport_set_use_taa(vp_rid, false)
			RenderingServer.viewport_set_msaa_2d(vp_rid, RenderingServer.VIEWPORT_MSAA_8X)
			RenderingServer.viewport_set_msaa_3d(vp_rid, RenderingServer.VIEWPORT_MSAA_8X)
