extends Control

var inventory_node: Node = null

var backpack_node: Node
var augments_node: Node
var item_selection_node: Node
var trash_slot_node: Node

var starter_items: Array[ItemResource] = [preload("res://Scripts/items/prototype/Item6.tres"),preload("res://Scripts/items/prototype/Labrys.tres")]
var augment_items: Array[ItemResource] = []
var backpack_items: Array[ItemResource] = [] # pls don't clean me! [preload("res://Scripts/items/prototype/Item6.tres"),preload("res://Scripts/items/consumer/Item4.tres")] #[preload("res://Scripts/items/prototype/Item6.tres")]

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
	backpack_items.resize(backpack_node.get_child_count())
	for i in range(backpack_items.size()):
		var slot = backpack_node.get_child(i)
		var item_res = backpack_items[i]
		
		if backpack_items[i]:
			var item_control = create_item_control(item_res)
			slot.set_item(item_control)
	
	# setup augments
	augment_items.resize(augments_node.get_child_count())
	for i in range(augment_items.size()):
		var slot = augments_node.get_child(i)
		var item_res = augment_items[i]
		
		if augment_items[i]:
			var item_control = create_item_control(item_res)
			slot.set_item(item_control)
	
	equip_starter_items()

func init_slots() -> void:
	for i in range(backpack_node.get_child_count()):
		var slot = backpack_node.get_child(i)
		slot.setup()
	
	for i in range(augments_node.get_child_count()):
		var slot = augments_node.get_child(i)
		slot.setup()
	
	trash_slot_node.setup()
	item_selection_node.setup()

func create_item_control(item_res: ItemResource) -> Control:
	var instance: Control = item_scene.instantiate() as Control
	instance.item = item_res.duplicate(true)
	return instance

func move_item(origin_slot: InventorySlot, new_slot: InventorySlot = null) -> void:
	var item = origin_slot.get_item()
	
	if not item:
		return
	
	if item.get_parent():
		item.get_parent().remove_child(item)
	
	# item was dragged into a slot
	if new_slot:
		place_or_swap(item, origin_slot, new_slot)
	
	# item was right clicked
	elif origin_slot in backpack_node.get_children():
		new_slot = get_augment_slot(item)
		place_or_swap(item, origin_slot, new_slot)
	else:
		new_slot = get_backpack_slot()
		place_or_swap(item, origin_slot, new_slot)
	
	# item was from a pickup slot
	var pickup_slot := origin_slot as PickupSlot
	if pickup_slot:
		close_item_pickup_menu()
	
	update_inventory_data()

func place_or_swap(item: Control, origin_slot: Control, new_slot: Control) -> void:
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
	
	# update augments
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
	if not item:
		return
		
	#chaos, don't touch
	if item.weapon_type != ItemType.WeaponType.NONE:
		if item.attack_type == ItemType.AttackType.PRIMARY:
			ItemGlobals.primary = true
			item.set_primary_weapon_type_name()
			item.set_primary_attack_type_name()
			
		if item.attack_type == ItemType.AttackType.SECONDARY:
			ItemGlobals.secondary = true
			item.set_secondary_weapon_type_name()
			item.set_secondary_attack_type_name()
			
	#print("Applying effects for: ", item.item_name)
	for effect in item.effects:
		effect.apply_effect(GameManager.player)
	
	#reset the check
	ItemGlobals.primary = false
	ItemGlobals.secondary = false


func remove_item_effects(item: ItemResource) -> void:

	#chaos, don't touch
	if item.weapon_type != ItemType.WeaponType.NONE:
		if item.attack_type == ItemType.AttackType.PRIMARY:
			ItemGlobals.primary = true
			ItemGlobals.primary_weapon_type = "Default"
			
		if item.attack_type == ItemType.AttackType.SECONDARY:
			ItemGlobals.secondary = true
			ItemGlobals.secondary_weapon_type = "Default"
			
	#print("Removing effects for: ", item.item_name)
	for effect in item.effects:
		effect.remove_effect(GameManager.player)
			
	#reset the check
	ItemGlobals.primary = false
	ItemGlobals.secondary = false

func reset_inventory() -> void:
	augment_items.clear()
	backpack_items.clear()

func equip_starter_items() -> void:
	if starter_items.size() == 0:
		return
	
	"for i in range(starter_items.size()):
		var item_res = starter_items[i]
		var item_control = create_item(item_res)
		backpack_node.add_child(item_control)
		move_item()"
	
	for item in starter_items:
		var item_control = create_item_control(item)
		var slot = backpack_node.get_child(0)
		slot.set_item(item_control)
		move_item(slot)
		
