extends Node

var items=[null,null,null]


func _ready() -> void:
	items = generate_items()


func generate_items()->Array:
	#todo change this placeholder to actual items once they are implemented
	return [preload("res://Scenes/item.tscn").instantiate(), preload("res://Scenes/item.tscn").instantiate(), preload("res://Scenes/item.tscn").instantiate()]


func get_item(index:int)->Node:
	return items[index]
