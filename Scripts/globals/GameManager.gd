extends Node

var open_menu_count := 0

func open_menu() -> void:
	open_menu_count += 1
	get_tree().paused = true

func close_menu() -> void:
	open_menu_count -= 1
	if open_menu_count == 0:
		get_tree().paused = false

func set_menu(status: bool) -> void:
	match status:
		true: open_menu()
		false: close_menu()
