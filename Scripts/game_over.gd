extends Control

@onready var time_alive: RichTextLabel = $Panel/MarginContainer/VBoxContainer/time_alive
@onready var enemies_killed: RichTextLabel = $Panel/MarginContainer/VBoxContainer/enemies_killed
@onready var cause_of_death: RichTextLabel = $Panel/MarginContainer/VBoxContainer/cause_of_death
@onready var damage_dealt: RichTextLabel = $Panel/MarginContainer/VBoxContainer/damage_dealt
@onready var damage_taken: RichTextLabel = $Panel/MarginContainer/VBoxContainer/damage_taken
@onready var items_picked_up: RichTextLabel = $Panel/MarginContainer/VBoxContainer/items_picked_up

@onready var restart_button: Button = $Panel/MarginContainer/VBoxContainer/HBoxContainer/restart_button

var player:Player


func setup(p: Player) -> void:
	player = p
	player.game_over.connect(player_dead)


func player_dead()->void:
	visible=true
	time_alive.append_text(yellow_text(seconds_to_minute_and_seconds(GameStats.time_alive_seconds)))
	enemies_killed.append_text(yellow_text(str(GameStats.enemies_killed)))
	damage_dealt.append_text(yellow_text(str(GameStats.total_damage_dealt)))
	damage_taken.append_text(yellow_text(str(GameStats.total_damage_taken)))
	items_picked_up.append_text(yellow_text(str(GameStats.items_picked_up)))
	
	cause_of_death.append_text(red_text(GameStats.player_last_hit_by.enemy.name))
	
	restart_button.grab_focus()


func seconds_to_minute_and_seconds(seconds:int)->String:
	var minutes := 0
	while seconds > 59:
		minutes += 1
		seconds -= 60
	return "%02d:%02d" % [minutes, seconds]


func yellow_text(s:String)->String:
	return "[color=yellow]%s[/color]" % s


func red_text(s:String)->String:
	return "[color=red]%s[/color]" % s


func _on_restart_button_pressed() -> void:
	GameStats.reset_game_stats()
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
	visible = false


func _on_quit_button_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
