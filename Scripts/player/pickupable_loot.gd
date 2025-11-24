extends PickupableObject

@export var sprite := Sprite2D
@export var sprite_list: Array[CompressedTexture2D]

@export var item_scene: PackedScene

var items=[null,null,null]

func set_loot(rarity: ItemType.Grade) -> void:
	sprite.texture = sprite_list[randi_range(0, sprite_list.size() - 1)]
	sprite.modulate = LootDatabase.grade_colors.get(rarity)
	
	items = []
	var item_list = LootDatabase.get_items_by_rarity(rarity, 3)
	
	for res in item_list:
		var node = item_scene.instantiate()
		items.append(node)
		node.update_item_display(res)

func get_item(index:int)->Node:
	return items[index]
