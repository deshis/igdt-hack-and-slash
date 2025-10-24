extends Control

@onready var continue_button: Button = $Panel/MarginContainer/VBoxContainer/ContinueButton
@onready var panel: Panel = $Panel
@onready var settings_menu: Control = $SettingsMenu
@onready var master_volume_slider: HSlider = $SettingsMenu/TabContainer/Audio/VBoxContainer/MasterVolumeSlider
@onready var tab_container: TabContainer = $SettingsMenu/TabContainer


func _ready() -> void:
	visible = false


func toggle_pause()->void:
	visible = !visible
	get_tree().paused = !get_tree().paused
	continue_button.grab_focus()


func _unhandled_input(event):
	if event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			if settings_menu.visible:
				toggle_settings_menu()
			else:
				toggle_pause()


func _on_continue_button_pressed() -> void:
	toggle_pause()


func _on_settings_button_pressed() -> void:
	toggle_settings_menu()


func toggle_settings_menu()->void:
	panel.visible=!panel.visible
	settings_menu.visible=!settings_menu.visible
	
	if settings_menu.visible:
		tab_container.current_tab = 0 
		master_volume_slider.grab_focus()
	else:
		continue_button.grab_focus()


func _on_quit_button_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()


func _on_back_to_menu_button_pressed() -> void:
	toggle_settings_menu()
