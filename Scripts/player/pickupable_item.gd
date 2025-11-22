extends Node

@export var sprite := Sprite2D
@export var sprite_list: Array[CompressedTexture2D]

var items=[null,null,null]

var colors = [
	Color(0.788, 0.788, 0.788, 1.0),
	Color(0.0, 0.745, 0.0, 1.0),
	Color(1.0, 0.757, 0.0, 1.0)
]

func setup(rarity: int) -> void:
	sprite.texture = sprite_list[randi_range(0, sprite_list.size() - 1)]
	
	# TODO: choose loot pool based on rarity
	match rarity:
		0:
			sprite.modulate = colors[0]
		1:
			sprite.modulate = colors[1]
		2:
			sprite.modulate = colors[2]
	
	items = generate_items()


func generate_items()->Array:
	#todo change this placeholder to actual items once they are implemented
	return [preload("res://Scenes/item.tscn").instantiate(), preload("res://Scenes/item.tscn").instantiate(), preload("res://Scenes/item.tscn").instantiate()]


func get_item(index:int)->Node:
	return items[index]
