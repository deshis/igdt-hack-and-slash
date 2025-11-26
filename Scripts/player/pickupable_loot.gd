extends PickupableObject

@export var sprite := Sprite2D
@export var sprite_list: Array[CompressedTexture2D]

@export var item_scene: PackedScene

var items=[null,null,null]

func _ready() -> void:
	var interact = InputMap.action_get_events("interact")
	var button_name = OS.get_keycode_string(interact[0].physical_keycode)
	$RichTextLabel.text = button_name + " interact"

func _physics_process(_delta: float) -> void:
	if not player:
		return
	
	var dist = global_position.distance_to(player.global_position)
	if dist < 150.0:
		$RichTextLabel.visible = true
	else:
		$RichTextLabel.visible = false

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
