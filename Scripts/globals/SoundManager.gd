extends Node

var sfx_players: Dictionary = {}
var music_player: AudioStreamPlayer
var bgm_players: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create a player for background music
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	
	bgm_players = {
		"common_bgm": load("res://Assets/audio/bgm.mp3")
	}
	
	# TODO
	# Hard-coded bgm_player, go with this before we have a proper level system and bgm for different levels.
	music_player.stream = bgm_players["common_bgm"]
	music_player.play()
	
	sfx_players = {
		"light_attack": load("res://Assets/audio/effect_light_attack.wav"),
		"heavy_attack": load(""), # TODO
		"dash": load("res://Assets/audio/effect_dash.wav"),
		"hit": load("res://Assets/audio/effect_hit.wav")
	}
	
	

# Play one-shot sound effects
func play_sfx(name: String, position: Vector2 = Vector2.ZERO) -> void:
	
	if not sfx_players.has(name):
		push_warning("SFX not found: " + name)
		return
		
	var player := AudioStreamPlayer2D.new()
	player.stream = sfx_players[name]
	player.position = position
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
