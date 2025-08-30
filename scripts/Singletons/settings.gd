extends Node

var masterVolume = 100.0
var musicVolume = 100.0
var sfxVolume = 100.0
var screenShake = true
var fullscreen = true


func _setFullScreen(val: bool):
	get_window().fullscreen = val