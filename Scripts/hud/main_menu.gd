extends Node3D


func _on_play_pressed() -> void:
	GameManager.start_game_from_main_menu()


func _on_quit_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
