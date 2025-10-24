extends Button

@export var action: String


func _init() -> void:
	toggle_mode = true


func _ready() -> void:
	
	var keybinds = CfgHandler.load_keybinds()
	
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, keybinds[action])
	
	set_process_unhandled_input(false)
	update_key_text()


func update_key_text():
	text = InputMap.action_get_events(action)[0].as_text()


func _toggled(toggled_on: bool) -> void:
	set_process_unhandled_input(toggled_on)
	if toggled_on:
		text = "Press new button"
		release_focus()
	else:
		update_key_text()
		grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed():
		if event.is_action("ui_cancel"):
			button_pressed = false
		else:
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, event)
			CfgHandler.save_keybind(action, event)
			button_pressed = false
