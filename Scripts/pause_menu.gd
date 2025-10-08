extends Control

@onready var continue_button: Button = $Panel/MarginContainer/VBoxContainer/ContinueButton

func _ready() -> void:
	visible = false

func toggle_pause()->void:
	visible = !visible
	get_tree().paused = !get_tree().paused
	continue_button.grab_focus()
	
	
func _unhandled_input(event):
	if event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			toggle_pause()


func _on_continue_button_pressed() -> void:
	toggle_pause()


func _on_settings_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
