extends Control

@export var player: Player
@onready var inventory: Control = $".."

@onready var selection_slot_1: Panel = $VBoxContainer/MarginContainer/HBoxContainer/SelectionSlot1
@onready var selection_slot_2: Panel = $VBoxContainer/MarginContainer/HBoxContainer/SelectionSlot2
@onready var selection_slot_3: Panel = $VBoxContainer/MarginContainer/HBoxContainer/SelectionSlot3

var item_on_ground:Area2D

func _ready() -> void:
	player.item_picked_up.connect(open_item_selection)


func open_item_selection(area:Area2D):
	item_on_ground = area
	inventory.visible = true
	visible = true
	selection_slot_1.add_child(generate_item())
	selection_slot_2.add_child(generate_item())
	selection_slot_3.add_child(generate_item())


func generate_item():
	#todo change placeholder item to actual item once they are implemented
	return preload("res://Scenes/item.tscn").instantiate()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		visible = false


func _on_selection_slot_item_was_taken() -> void:
	visible = false
	item_on_ground.queue_free()
