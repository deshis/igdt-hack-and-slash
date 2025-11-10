extends Control
class_name InventorySlot

@export var slot_name: String
@export var type: ItemType.Type

var player: Player
var inventory_manager: InventoryManager

signal item_was_taken

func setup(p: Player, inv_manager: InventoryManager) -> void:
	player = p
	inventory_manager = inv_manager
	
	get_child(0).text = slot_name

func get_item() -> Control:
	for child in get_children():
		if child is Item:
			return child
	return null

func set_item(item: Control) -> void:
	clear_item()
	add_child(item)

func clear_item() -> void:
	for child in get_children():
		if child is Item:
			child.queue_free()

func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	if typeof(data) != TYPE_DICTIONARY:
		return false
	
	var item = data.get("item", null)
	if not item:
		return false
	
	# generic slot
	if type == ItemType.Type.NONE:
		return true
	
	return item.get_type() == type

func _drop_data(_pos: Vector2, data: Variant) -> void:
	var item: Control = data.get("item", null)
	var origin_slot: Control = data.get("origin_slot", null)
	
	if typeof(data) != TYPE_DICTIONARY:
		return
	
	inventory_manager.move_item(item, self, origin_slot)
