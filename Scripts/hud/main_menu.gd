extends Node3D

func _ready() -> void:
	$Menu/MarginContainer/VBoxContainer/Play.add_to_group("start_button")

func _on_play_pressed() -> void:
	GameManager.restart()


func _on_quit_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
