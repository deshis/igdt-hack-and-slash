extends Control
class_name Item

@export var item : ItemResource

@onready var type = item.type
@onready var grade = item.grade
@onready var description = $PanelContainer/RichTextLabel
@onready var texture_rect = $MarginContainer/TextureRect
@onready var panel_container1 = $PanelContainer

var name_color = "#b5b5b5"
var grade_name = "?"
var type_name = "?"
var stats = "?"

func _ready() -> void:
	if item != null and texture_rect != null:
		panel_container1.visible = false
		texture_rect.texture = item.icon
		_set_grade()
		_get_type_name()
		_create_description()

#Not functional!
func _position_description() -> void:
	var item_pos = get_global_position()
	var offset_x = -25
	var offset_y = -15
	var new_pos = item_pos + Vector2(offset_x, offset_y)
	panel_container1.global_position = new_pos

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
	
	var texture = $MarginContainer/TextureRect
	texture.modulate = Color(1,1,1,0.5)
	
	if item != null:
		description.visible = false
		panel_container1.visible = false
		
	return get_parent()

func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		texture_rect.modulate = Color(1,1,1,1)

func _input(event: InputEvent) -> void:
	if event.is_action_released("click"):
		pass
		var texture = $MarginContainer/TextureRect
		texture.modulate = Color(1,1,1,1)
		
	if event.is_action_pressed("click"):
		pass
		description.visible = false
		panel_container1.visible = false

#Godot has switch statements with match
func _set_grade() -> void:
	match item.grade: 
		ItemType.Grade.CONSUMER:
			name_color = "#b5b5b5"
			grade_name = "Consumer"
		ItemType.Grade.MILITARY:
			name_color = "#fffa70"
			grade_name = "Military"
		ItemType.Grade.PROTOTYPE:
			name_color = "#ff3838"
			grade_name = "Prototype"

func _get_type_name() -> void:
	match item.type: 
		ItemType.Type.SURVIVABILITY:
			type_name = "Survivability"
		ItemType.Type.MOVEMENT:
			type_name = "Movement"
		ItemType.Type.UTILITY:
			type_name = "Utility"
		ItemType.Type.DAMAGE:
			type_name = "Damage"
		ItemType.Type.ACTIVE_ITEM:
			type_name = "Active Item"
		ItemType.Type.PRIMARY_ATTACK:
			type_name = "Primary Attack"
		ItemType.Type.SECONDARY_ATTACK:
			type_name = "Secondary Attack"

func _create_description() -> void:
	
	name = item.item_name
	var formatted_desc = ""
	
	#Item name
	var formatted_name = ""
	formatted_name += "[center][color=" + name_color + "][b]" + item.item_name + "[/b][/color][/center]\n\n"
	formatted_desc += formatted_name

	#Item stat info
	#formatted_desc += "[center][color=" + "#bdbbbb" + "]" + item.item_stat_info + "[/color][/center]\n\n"
	
	formatted_desc += item.get_formatted_stats()
	
	#Item grade
	formatted_desc += "\n[center][color=" + name_color + "]" + grade_name + "[/color][/center]\n"
	
	#Item type
	formatted_desc += "[center][color=" + name_color + "]" + type_name + "[/color][/center]\n"
	
	#Item description
	formatted_desc += "[center][color=" + "#bdbbbb" + "]" + item.item_description + "[/color][/center]\n"
	
	
	
	description.set_text(formatted_desc)

func _on_mouse_entered() -> void:
	if item == null:
		return
		
	#Busted, fix later
	_position_description()
	
	description.visible = true
	panel_container1.visible = true

func _on_mouse_exited() -> void:
	if item == null:
		return
	
	description.visible = false
	panel_container1.visible = false
