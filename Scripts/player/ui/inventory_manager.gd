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
		
		# for items already in backpack on init
		var item = child.get_item()
		if item:
			item.item_right_clicked.connect(_on_item_right_clicked)
	
	for child in augment_slots.get_children():
		child.setup(p, self)
	
	item_selection.setup(p, self)
	trash_slot.setup(p, self)

func move_item(item: Control, new_slot: Control = null, origin_slot: InventorySlot = null) -> void:
	
	var none = ItemType.Type.NONE
	
	# item was dragged into a slot
	if new_slot:
		# trash item
		if new_slot == trash_slot:
			delete_item(item)
			
			if origin_slot.get_parent() == item_selection:
				close_item_pickup_menu()
		# backpack -> equipment slot
		if origin_slot.type == none and new_slot.type != none:
			# remove child, add child, equip item
			equip_item(item, new_slot)
		# equipment -> backpack
		elif origin_slot.type != none and new_slot.type == none:
			unequip_item(item, new_slot)
		# backpack -> anything (only backpack possible)
		elif origin_slot in backpack.get_children():
			unequip_item(item, new_slot)
		# item selection -> anything
		else:
			if new_slot in augment_slots.get_children():
				equip_item(item, new_slot)
			else:
				unequip_item(item, new_slot)
			
			close_item_pickup_menu()
	
	# item was right clicked
	elif origin_slot in backpack.get_children():
		equip_item(item, null)
	elif origin_slot in augment_slots.get_children():
		unequip_item(item, null)
	else:
		equip_item(item, null)
		close_item_pickup_menu()

func equip_item(item: Control, new_slot: Control = null) -> void:
	if item.get_parent():
		item.get_parent().remove_child(item)
	
	# item was dragged into a slot
	if new_slot:
		new_slot.set_item(item)
		add_item(item)
		return
	
	# item was right clicked
	var item_type = item.get_type()
	
	for slot in augment_slots.get_children():
		if slot.type == item_type:
			if slot.get_item() != null:
				unequip_item(slot.get_item(), null)
			
			slot.set_item(item)

func unequip_item(item: Control, new_slot: Control) -> void:
	if item.get_parent():
		item.get_parent().remove_child(item)
		
	# item was dragged into a slot
	if new_slot:
		new_slot.set_item(item)
		remove_item(item)
		return
	
	# item was right clicked
	for slot in backpack.get_children():
		if slot.get_item() == null:
			slot.set_item(item)
			remove_item(item)
			return

func add_item(item: Control) -> void:
	var item_res: ItemResource = item.item
	
	if equipped_items.has(item_res):
		return
	
	equipped_items.append(item_res)
	apply_item_effects(item_res)

func remove_item(item: Control) -> void:
	var item_res: ItemResource = item.item
	
	if equipped_items.has(item_res):
		equipped_items.erase(item_res)
		remove_item_effects((item_res))

func delete_item(item: Control):
	remove_item(item)
	item.queue_free()

func apply_item_effects(item: ItemResource) -> void:
	# print("Applying effects for: ", item.item_name)
	for effect in item.effects:
		effect.apply_effect(player)

func remove_item_effects(item: ItemResource) -> void:
	# print("Removing effects for: ", item.item_name)
	for effect in item.effects:
		effect.remove_effect(player)

func close_item_pickup_menu() -> void:
	item_selection._on_selection_slot_item_was_taken()


func _on_item_right_clicked(item: Control) -> void:
	var slot = item.get_parent()
	move_item(item, null, slot)
