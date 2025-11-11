extends Control
class_name InventoryManager

@export var backpack: Node
@export var augment_slots: Node
@export var item_selection: Node
@export var trash_slot: Node

var player: Player
var equipped_items: Array[ItemResource]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		self.visible = !self.visible

func setup_inventory(p: Player) -> void:
	player = p
	
	for child in backpack.get_children():
		child.setup(p, self)
	
	for child in augment_slots.get_children():
		child.setup(p, self)
	
	item_selection.setup(p, self)
	trash_slot.setup(p, self)

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
	elif origin_slot in backpack.get_children():
		new_slot = get_augment_slot(item)
		check_and_swap_items(item, origin_slot, new_slot)
	else:
		new_slot = get_backpack_slot()
		check_and_swap_items(item, origin_slot, new_slot)
	
	# item was from a pickup slot
	var pickup_slot := origin_slot as PickupSlot
	if pickup_slot:
		close_item_pickup_menu()

func check_and_swap_items(item: Control, origin_slot: Control, new_slot: Control) -> void:
	if not new_slot:
		return
	
	if new_slot.get_item():
		var item_to_swap = new_slot.get_item()
		new_slot.remove_child(item_to_swap)
		origin_slot.set_item(item_to_swap)
	
	new_slot.set_item(item)

func equip_item(item: Control) -> void:
	var item_res: ItemResource = item.item
	
	if equipped_items.has(item_res):
		return
	
	equipped_items.append(item_res)
	apply_item_effects(item_res)

func unequip_item(item) -> void:
	var item_res: ItemResource = item.item
	
	if equipped_items.has(item_res):
		equipped_items.erase(item_res)
		remove_item_effects((item_res))

func delete_item(item: Control):
	unequip_item(item)
	item.queue_free()

func get_augment_slot(item) -> Control:
	for slot in augment_slots.get_children():
		if slot.type == item.type:
			return slot
	return null

func get_backpack_slot() -> Control:
	for slot in backpack.get_children():
		if slot.get_item() == null:
			return slot
	return null

func close_item_pickup_menu() -> void:
	item_selection.close_menu()

func apply_item_effects(item: ItemResource) -> void:
	# print("Applying effects for: ", item.item_name)
	for effect in item.effects:
		effect.apply_effect(player)

func remove_item_effects(item: ItemResource) -> void:
	# print("Removing effects for: ", item.item_name)
	for effect in item.effects:
		effect.remove_effect(player)
