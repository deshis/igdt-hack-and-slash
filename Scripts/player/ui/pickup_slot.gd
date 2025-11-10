extends InventorySlot

func setup(p: Player, inv_manager: InventoryManager) -> void:
	player = p
	inventory_manager = inv_manager
	
	is_pickup_slot = true
	
	get_child(0).text = slot_name
