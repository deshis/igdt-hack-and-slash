extends Control

@export var text: String

@onready var tooltip:RichTextLabel = $RichTextLabel


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	tooltip.add_text(text)

@export var type : ItemType.Type
func get_type() -> int:
	return type

func _get_drag_data(_pos: Vector2) -> Variant:
	var preview := duplicate(true)
	
	preview.anchor_left = 0
	preview.anchor_top = 0
	preview.anchor_right = 0
	preview.anchor_bottom = 0
	preview.size = size
	
	set_drag_preview(preview)
	
	tooltip.visible = false
	var texture = $MarginContainer/TextureRect
	texture.modulate = Color(1,1,1,0.5)
	
	return {
		"item": self,
		"origin_slot": get_parent()
	}

func _input(event: InputEvent) -> void:
	if event.is_action_released("click"):
		var texture = $MarginContainer/TextureRect
		texture.modulate = Color(1,1,1,1)

func _on_mouse_entered() -> void:
	tooltip.visible = true

func _on_mouse_exited() -> void:
	tooltip.visible = false
