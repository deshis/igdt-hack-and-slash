extends Control

@export var player: Player


@export var backpack: GridContainer
@export var item_hp: Panel
@export var item_att: Panel
@export var item_as: Panel
@export var item_ms: Panel

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		self.visible = !self.visible

func addItem(itemRef:Item)-> bool:
	for slot in backpack.get_children():
		if slot.get_item() == null:
			var newItemInstance = itemRef.duplicate()
			newItemInstance.type = ItemType.Type.BACKPACK
			slot.set_item(newItemInstance.get_child(0))
			player.incrementItem(itemRef)
			return true
	return false
	
