extends InventorySlot

func set_item(item: Control) -> void:
	inventory_manager.unequip_item(item)
	item.queue_free()
