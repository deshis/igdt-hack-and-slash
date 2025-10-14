extends Control

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		self.visible = !self.visible
