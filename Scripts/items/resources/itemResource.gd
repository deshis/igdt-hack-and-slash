extends Resource
class_name ItemResource

@export var item_name: String
@export var item_description: String
@export var type: ItemType.Type
@export var grade: ItemType.Grade
@export var icon: Texture2D
@export var effects: Array[Stats] = []
