extends Control

@export var backpack: Node
@export var augment_slots: Node
@export var item_selection: Node

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		self.visible = !self.visible

func setup_inventory(p: Player) -> void:
	for child in backpack.get_children():
		child.player = p
	
	for child in augment_slots.get_children():
		child.player = p
	
	item_selection.setup(p)
