extends Node
class_name Item
@export var item_name: String = "Unkown Item"

@export var Effect: Sprite2D
@export var Health: int
@export var Attack: int
@export var Attack_speed: int
@export var Movement_speed: int

@export var type: ItemType.Type = ItemType.Type.NOTPICKEDUP

@export var text : String = "n/a"



func get_type() -> int:
	return type


@onready var UI:Control =$UI
func _ready() -> void:
	UI.text=text
	UI.type=type
