extends Node


func _ready():
	print("starting timer")
	var timer:Timer= $"../Timer"
	timer.start()


func _init():
	_ready()
