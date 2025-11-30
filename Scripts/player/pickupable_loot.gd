extends PickupableObject

@export var sprite := Sprite2D
@export var sprite_list: Array[CompressedTexture2D]

@export var item_scene: PackedScene

var items := [ItemResource]

func _ready() -> void:
	var interact = InputMap.action_get_events("interact")
	var button_name = interact[0].as_text()
	$RichTextLabel.text = button_name + " interact"

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
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
		items.append(res.duplicate(true))

func get_item(index:int) -> ItemResource:
	return items[index]
