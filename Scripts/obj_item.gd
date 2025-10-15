extends Area2D

@export var itemRef:Item


func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "Player":
		if body.inventory.addItem(itemRef):
			queue_free()
