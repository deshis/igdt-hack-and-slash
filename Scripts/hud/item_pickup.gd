extends Control

var player: Player
var inventory_manager: InventoryManager
@onready var inventory: Control = $".."

@onready var selection_slot_1: Control = $VBoxContainer/MarginContainer/HBoxContainer/SelectionSlot1
@onready var selection_slot_2: Control = $VBoxContainer/MarginContainer/HBoxContainer/SelectionSlot2
@onready var selection_slot_3: Control = $VBoxContainer/MarginContainer/HBoxContainer/SelectionSlot3

var item_on_ground:Area2D

func setup(p: Player, inv_manager: InventoryManager) -> void:
	player = p
	inventory_manager = inv_manager
	
	selection_slot_1.setup(p, inv_manager)
	selection_slot_2.setup(p, inv_manager)
	selection_slot_3.setup(p, inv_manager)
	
	player.item_picked_up.connect(open_item_selection)

func open_item_selection(area:Area2D):
	item_on_ground = area
	inventory.visible = true
	visible = true
	
	clear_slot(selection_slot_1)
	clear_slot(selection_slot_2)
	clear_slot(selection_slot_3)
	
	var item1 = area.get_item(0).duplicate()
	var item2 = area.get_item(1).duplicate()
	var item3 = area.get_item(2).duplicate()
	
	selection_slot_1.add_child(item1)
	selection_slot_2.add_child(item2)
	selection_slot_3.add_child(item3)
	
	visible = true
	GameManager.open_menu()


func clear_slot(slot: Control)->void:
	for child in slot.get_children():
		if child is Item:
			child.queue_free()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		visible = false

func close_menu() -> void:
	visible = false
	item_on_ground.queue_free()
