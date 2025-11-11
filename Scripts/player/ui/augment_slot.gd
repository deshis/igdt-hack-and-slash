extends InventorySlot

func get_item() -> Control:
	for child in get_children():
		if child is Item:
			inventory_manager.unequip_item(child)
			return child
	return null

func set_item(item: Control) -> void:
	clear_item()
	add_child(item)
	inventory_manager.equip_item(item)

func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	if not (data is InventorySlot):
		return false
	
	var origin_slot: InventorySlot = data
	var item = origin_slot.get_item()
	
	return item.get_type() == type
