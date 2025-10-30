extends Control
@export var player: Player

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS

func get_item() -> Control:
	return get_child(0) if get_child_count() > 0 else null

func set_item(item: Control) -> void:
	clear_item()
	add_child(item)
	item.visible = true
	
	if item.item.equipped:
		for effect in item.item.effects:
			#print("Removing effects")
			effect.remove_effect(player)
		item.item.equipped = false

func clear_item() -> void:
	if get_child_count() > 0:
		get_child(0).queue_free()

func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	
	var item = data.get("item", null)
	if not item:
		return false
		
	return true

func _drop_data(_pos: Vector2, data: Variant) -> void:
	var dragged: Control = data.get("item", null)
	var origin_slot: Control = data.get("origin_slot", null)
	
	var existing := get_item()
	if existing:
		origin_slot.set_item(existing)
		
	if dragged.get_parent():
		dragged.get_parent().remove_child(dragged)
	
	set_item(dragged)
