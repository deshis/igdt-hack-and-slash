extends Control

var inventory_node: Node = null

var backpack_node: Node
var augments_node: Node
var item_selection_node: Node
var trash_slot_node: Node

var augment_items: Array[ItemResource] = [null, null, null, null, null, null, null]
var backpack_items: Array[ItemResource] = [preload("res://Scripts/items/prototype/Item6.tres"), null, null, null, null, null]

var item_scene: PackedScene = preload("res://Scenes/item.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		inventory_node.visible = !inventory_node.visible
		GameManager.set_menu(inventory_node.visible)

func init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# setup inventory
	inventory_node = GameManager.HUD.get_node("Inventory")
	backpack_node = inventory_node.get_node("Backpack")
	augments_node = inventory_node.get_node("AugmentSlots")
	trash_slot_node = inventory_node.get_node("TrashSlot")
	item_selection_node = inventory_node.get_node("ItemSelection")
	init_slots()
	
	# setup backpack
	for i in range(backpack_items.size()):
		var slot = backpack_node.get_child(i)
		var item_res = backpack_items[i]
		
		if backpack_items[i]:
			var item_control = create_item(item_res)
			slot.set_item(item_control)
	
	# setup augments
	for i in range(augment_items.size()):
		var slot = augments_node.get_child(i)
		var item_res = augment_items[i]
		
		if augment_items[i]:
			var item_control = create_item(item_res)
			slot.set_item(item_control)
	
	# apply effects
	for item_res in augment_items:
		apply_item_effects(item_res)

func init_slots() -> void:
	for i in range(backpack_node.get_child_count()):
		var slot = backpack_node.get_child(i)
		slot.setup()
	
	for i in range(augments_node.get_child_count()):
		var slot = augments_node.get_child(i)
		slot.setup()
	
	trash_slot_node.setup()
	item_selection_node.setup()

func create_item(item_res: ItemResource) -> Control:
	var instance: Control = item_scene.instantiate() as Control
	instance.item = item_res
	return instance

func move_item(origin_slot: InventorySlot, new_slot: InventorySlot = null) -> void:
	var item = origin_slot.get_item()
	
	if not item:
		return
	
	if item.get_parent():
		item.get_parent().remove_child(item)
	
	# item was dragged into a slot
	if new_slot:
		check_and_swap_items(item, origin_slot, new_slot)
	
	# item was right clicked
	elif origin_slot in backpack_node.get_children():
		new_slot = get_augment_slot(item)
		check_and_swap_items(item, origin_slot, new_slot)
	else:
		new_slot = get_backpack_slot()
		check_and_swap_items(item, origin_slot, new_slot)
	
	# item was from a pickup slot
	var pickup_slot := origin_slot as PickupSlot
	if pickup_slot:
		close_item_pickup_menu()
	
	update_inventory_data()

func check_and_swap_items(item: Control, origin_slot: Control, new_slot: Control) -> void:
	if not new_slot:
		return
	
	if new_slot.get_item():
		var item_to_swap = new_slot.get_item()
		new_slot.remove_child(item_to_swap)
		origin_slot.set_item(item_to_swap)
	
	new_slot.set_item(item)
	update_inventory_data()

func delete_item(item: Control):
	item.queue_free()

func get_augment_slot(item) -> Control:
	for slot in augments_node.get_children():
		if slot.type == item.item.type:
			return slot
	return null

func get_backpack_slot() -> Control:
	for slot in backpack_node.get_children():
		if slot.get_item() == null:
			return slot
	return null

func close_item_pickup_menu() -> void:
	item_selection_node.close_menu()


func update_inventory_data() -> void:
	# update backpack
	for i in range(backpack_node.get_child_count()):
		var slot = backpack_node.get_child(i)
		var new_item = slot.get_item().item if slot.get_item() else null
		backpack_items[i] = new_item
	
	for i in range(augments_node.get_child_count()):
		var slot = augments_node.get_child(i)
		
		var old_item = augment_items[i]
		var new_item = slot.get_item().item if slot.get_item() else null
		
		update_item_effects(old_item, new_item)
		augment_items[i] = new_item

func update_item_effects(old_item: ItemResource, new_item: ItemResource) -> void:
	if old_item and old_item != new_item:
		remove_item_effects(old_item)
	
	if new_item and old_item != new_item:
		apply_item_effects(new_item)

func apply_item_effects(item: ItemResource) -> void:
	# print("Applying effects for: ", item.item_name)
	if not item:
		return
	
	for effect in item.effects:
		effect.apply_effect(GameManager.player)

func remove_item_effects(item: ItemResource) -> void:
	# print("Removing effects for: ", item.item_name)
	for effect in item.effects:
		effect.remove_effect(GameManager.player)
