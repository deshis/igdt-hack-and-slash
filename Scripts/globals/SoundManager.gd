extends Node

var sfx_players: Dictionary = {}
var sfx_pitch_ranges: Dictionary = {}
var music_player: AudioStreamPlayer
var bgm_players: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# BGM part
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	
	bgm_players = {
		"common_bgm": load("res://Assets/audio/bgm.mp3")
		
	}
	
	# TODO Hard-coded bgm_player, go with this before we have a proper level system and bgm for different levels.
	music_player.stream = bgm_players["common_bgm"]
	music_player.play()
	
	
	# SFX part
	sfx_players = {
		"light_attack": load("res://Assets/audio/effect_light_attack.wav"),
		"heavy_attack": load("res://Assets/audio/effect_heavy_attack.wav"), 
		"dash": load("res://Assets/audio/effect_dash.wav"),
		"hit": load("res://Assets/audio/effect_hit.wav"),
		"enemy_die": load("res://Assets/audio/effect_enemy_die.wav"),
		"dot_sfx": load("res://Assets/audio/effect_dot.wav"),
		"heal":load("res://Assets/audio/effect_heal.wav"),
		"freeze_sfx":load("res://Assets/audio/effect_freeze.wav")
	}
	
	sfx_pitch_ranges = {
		"light_attack": [0.5, 1.5],
		"heavy_attack": [0.9, 1.2],
		"dash": [0.5, 1.5],
		"hit": [0.5, 1.2],
		"enemy_die": [0.5, 1.5],
		"dot_sfx": [0.5, 1.5],
		"heal": [0.5, 1.0]
	}

# Play one-shot sound effects
func play_sfx(name: String, position: Vector2 = Vector2.ZERO) -> void:
	
	if not sfx_players.has(name):
		push_warning("SFX not found: " + name)
		return
		
	var player := AudioStreamPlayer2D.new()
	player.stream = sfx_players[name]
	player.position = position
	
	player.bus = "SFX"
	
	# Pitch variation
	var pitch_range = sfx_pitch_ranges.get(name, [0.9, 1.1])
	player.pitch_scale = randf_range(pitch_range[0], pitch_range[1])
	
	add_child(player)
	player.play()
	
	player.finished.connect(player.queue_free)
