extends TabContainer


@onready var buttons := [
	$Controls/VBoxContainer/moveup/ControlRemapButton, 
	$Controls/VBoxContainer/movedown/ControlRemapButton, 
	$Controls/VBoxContainer/moveleft/ControlRemapButton,
	$Controls/VBoxContainer/moveright/ControlRemapButton,
	$Controls/VBoxContainer/dash/ControlRemapButton,
	$Controls/VBoxContainer/inventory/ControlRemapButton,
	$Controls/VBoxContainer/primary/ControlRemapButton,
	$Controls/VBoxContainer/secondary/ControlRemapButton,
	$Controls/VBoxContainer/interact/ControlRemapButton,
	]

func _ready() -> void:
	for button in buttons:
		button.stop_taking_mouse_input.connect(_stop_taking_mouse_input)
		button.start_taking_mouse_input.connect(_start_taking_mouse_input)

func _stop_taking_mouse_input() -> void:
	set_mouse_behavior_recursive(MouseBehaviorRecursive.MOUSE_BEHAVIOR_DISABLED)

func _start_taking_mouse_input() -> void:
	set_mouse_behavior_recursive(MouseBehaviorRecursive.MOUSE_BEHAVIOR_INHERITED)
