extends Node3D

func _ready() -> void:
	# Add SFX to buttons
	$Menu/MarginContainer/VBoxContainer/Play.add_to_group("start_button")
	$Menu/MarginContainer/VBoxContainer/Settings.add_to_group("ui_button")
	$Menu/MarginContainer/VBoxContainer/Tutorial.add_to_group("ui_button")
	$Menu/MarginContainer/VBoxContainer/Credits.add_to_group("ui_button")
	$Menu/MarginContainer/VBoxContainer/Quit.add_to_group("ui_button")

func _on_play_pressed() -> void:
	GameManager.restart()


func _on_quit_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
