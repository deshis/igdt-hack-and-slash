extends Control

var player: Player = GameManager.player

@onready var dash_cooldown_progress_bar: ProgressBar = $MarginContainer/HBoxContainer/DashCooldown/ProgressBar
@onready var dash_cooldown_timer: Timer = $MarginContainer/HBoxContainer/DashCooldown/Timer

@onready var primary_attack_progress_bar: ProgressBar = $MarginContainer/HBoxContainer/PrimaryAttack/ProgressBar
@onready var primary_attack_timer: Timer = $MarginContainer/HBoxContainer/PrimaryAttack/Timer

@onready var secondary_attack_progress_bar: ProgressBar = $MarginContainer/HBoxContainer/SecondaryAttack/ProgressBar
@onready var secondary_attack_timer: Timer = $MarginContainer/HBoxContainer/SecondaryAttack/Timer

@onready var active_item_progress_bar: ProgressBar = $MarginContainer/HBoxContainer/ActiveItemCooldown/ProgressBar
@onready var active_item_timer: Timer = $MarginContainer/HBoxContainer/ActiveItemCooldown/Timer

func _ready() -> void:
	if not player:
		return
	
	player.dash_used.connect(update_dash_cooldown)
	player.primary_attack_used.connect(update_primary_cooldown)
	player.secondary_attack_used.connect(update_secondary_cooldown)
	player.active_item_used.connect(update_active_item_cooldown)
	
func _process(_delta: float) -> void:
	dash_cooldown_progress_bar.value = dash_cooldown_timer.time_left
	primary_attack_progress_bar.value = primary_attack_timer.time_left
	secondary_attack_progress_bar.value = secondary_attack_timer.time_left
	active_item_progress_bar.value = active_item_timer.time_left
	
func update_dash_cooldown(cooldown:float)->void:
	dash_cooldown_progress_bar.max_value = cooldown
	dash_cooldown_progress_bar.value = cooldown
	dash_cooldown_timer.start(cooldown)

func update_primary_cooldown(cooldown:float)->void:
	primary_attack_progress_bar.max_value = cooldown
	primary_attack_progress_bar.value = cooldown
	primary_attack_timer.start(cooldown)

func update_secondary_cooldown(cooldown:float)->void:
	secondary_attack_progress_bar.max_value = cooldown
	secondary_attack_progress_bar.value = cooldown
	secondary_attack_timer.start(cooldown)
	
func update_active_item_cooldown(cooldown:float)->void:
	active_item_progress_bar.max_value = cooldown
	active_item_progress_bar.value = cooldown
	active_item_timer.start(cooldown)
	
	
