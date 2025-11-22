extends Sprite2D

@onready var model = $"../SubViewport/model"

func update_sprite(direction):
	model.rotate_model(direction)


func _process(_delta):
	rotation = -get_parent().global_rotation
